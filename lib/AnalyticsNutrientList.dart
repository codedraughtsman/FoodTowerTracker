import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/HelpButton.dart';
import 'package:foodtowertracker/SetNutrentLevels.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';
import 'TowerPageTodayOnly.dart';

class AnalyticsNutrientList extends StatefulWidget {
  @override
  _AnalyticsNutrientListState createState() => _AnalyticsNutrientListState();
}

class _AnalyticsNutrientListState extends State<AnalyticsNutrientList> {
  SelectBloc bloc;
  SelectBloc weeklyBloc;
  SelectBloc blocNutrientLevels;

  @override
  void initState() {
    void printWrapped(String text) {
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(text).forEach((match) => print(match.group(0)));
    }

    super.initState();
    this.bloc = SelectBloc(
      query: DBProvider.getDailyTotals(dateTime: DateTime.now()),
      table: "foodData",
      verbose: true,
      database: DBProvider.db,
    );
    printWrapped(bloc.toString());
    this.weeklyBloc = SelectBloc(
      query: DBProvider.getWeeklyTotals(dateTime: DateTime.now()),
      table: "foodData",
      verbose: true,
      database: DBProvider.db,
    );
    this.blocNutrientLevels = SelectBloc(
      table: "nutrientSettings",
      columns: "*",
      verbose: true,
      database: DBProvider.db,
    );
  }

  _onTap(String key) {
    var t = MaterialPageRoute(
      builder: (context) => TowerPageTodayOnly(
        dropdownValue: key,
      ),
    );
    Navigator.push(
      context,
      t,
    );
  }

  _onTap_openNutrientLevelsPage() {
    var t = MaterialPageRoute(
      builder: (context) => SetNutrentLevels(),
    );
    Navigator.push(
      context,
      t,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrients'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Set Levels",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _onTap_openNutrientLevelsPage,
          ),
          HelpButton("Help - Nutrients",
              """Here is where you can see the nutritional composition of what you have eaten today.

Tap on a nutrient to open a tower view of the foods that you have eaten with that nutrient.

Units:
    g - Grams
    mg - Milligram. 1000 mg = 1g
    μg - Microgram. Also abbreviated to mcg. 
           1000 μg = 1 mg"""),
        ],
      ),
      body: StreamBuilder<List<Map>>(
        stream: bloc.items,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return StreamBuilder<List<Map>>(
            stream: weeklyBloc.items,
            builder: (
              BuildContext context,
              AsyncSnapshot snapshotWeekly,
            ) {
              return StreamBuilder<List<Map>>(
                stream: blocNutrientLevels.items,
                builder: (
                  BuildContext context,
                  AsyncSnapshot snapshotNutrientLevels,
                ) {
                  if (!snapshotWeekly.hasData ||
                      !snapshot.hasData ||
                      !snapshotNutrientLevels.hasData) {
                    return FittedBox(
                      fit: BoxFit.contain,
                      child: CircularProgressIndicator(),
                    );
                  }
                  return _buildBody(context, snapshot, snapshotWeekly,
                      snapshotNutrientLevels);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(context, snapshot, snapshotWeekly, snapshotNutrientLevels) {
    log("snapshot weekly data : ${snapshotWeekly.data}");
    if (snapshot.hasData) {
      if (snapshot.data.length == 0) {
        return Padding(
          padding: new EdgeInsets.all(16.0),
          child: Text(
              "No food entries for today. Add entries using the '+' button"),
        );
      }
      log("snapshot data: ${snapshot.data}");
      var keys = DBProvider.getPortionsKeys();

      //remove keys we don't want to show.
      keys.remove("energy(NIP)");
      keys.remove("measure");

      return Padding(
        padding: new EdgeInsets.all(16.0),
        child: ListView.separated(
            padding: EdgeInsets.only(top: 16.0),
            itemCount: keys.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              var key = keys[index];
              Map<String, dynamic> mapped = snapshot.data[0];

              double value = 0;
              if (mapped[key] != null) {
                //there is no valid entry of portions for this date.
                //so just set the value of food eaten to 0.
                value = double.parse(mapped[key].toString());
              }
              double weeklyValue = 0;
              return _buildRow(key, value, weeklyValue);
            }),
      );
    } else {
      // the select query is still running

    }
  }

  Widget _buildRow(String key, double value, double weeklyValue) {
    return ListTile(
      onTap: () {
        _onTap(key);
      },
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FittedBox(
            child: Text(
              DBProvider.humanReadableNames[key],
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildIcon(key, value),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("Consumed: "),
                      Text(
                        DBProvider.doubleToStringConverter(value) +
                            " " +
                            DBProvider.getUnit(key),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                  buildRange(key),
                  buildText(key, "upperLimit"),
                ],
              )
            ],
          ),
          Container(
            height: 10,
            color: Colors.transparent,
          ),
          buildProgressBar(key, value),
        ],
      ),
    );
  }

  buildBar(double value, double upperLimit, {double lowerLimit = -1}) {
    Color rangeColour = Colors.green;
    Color endCapColour = Colors.black12;

    double scaleFactor = 10000;
    if (lowerLimit == -1) {
      // A lower limit is not set.
      // It is a max limit bar.
      lowerLimit = upperLimit;
      upperLimit += lowerLimit * 0.1;
      rangeColour = Colors.red;
      endCapColour = rangeColour;
    } else if (upperLimit == lowerLimit) {
      //It is a range bar, and we need to add a bit more if
      //upper limit is the lower limit.
      upperLimit += lowerLimit * 0.1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Row(
            //background
            children: <Widget>[
              Expanded(
                flex: (lowerLimit * scaleFactor).toInt(),
                child: Container(
                  color: Colors.black12,
                ),
              ),
              Expanded(
                flex: ((upperLimit - lowerLimit) * scaleFactor).toInt(),
                child: Container(
                  color: rangeColour,
                ),
              ),
              if (value > upperLimit)
                Expanded(
                  flex: ((value - upperLimit) * scaleFactor).toInt(),
                  child: Container(
                    color: endCapColour,
                  ),
                ),
            ],
          ),
          Container(
            height: 20,
            child: Row(
              //progress bar
              children: <Widget>[
                Expanded(
                  flex: (value * scaleFactor).toInt(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  flex: ((upperLimit - value) * scaleFactor).toInt(),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildProgressBar(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }

    return
//      color: Colors.grey,
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Progress towards RDI",
          style: TextStyle(fontSize: 14),
        ),
        Container(
          height: 2,
          color: Colors.transparent,
        ),
        Container(
          height: 40,
          child: buildBar(actualValue, map[key]["rangeMax"],
              lowerLimit: map[key]["rangeMin"]),
        ),
        Container(
          height: 10,
          color: Colors.transparent,
        ),
        if (map[key]["upperLimit"] != -1)
          Text(
            "Progress on Daily Maximum",
            style: TextStyle(fontSize: 14),
          ),
        if (map[key]["upperLimit"] != -1)
          Container(
            height: 2,
            color: Colors.transparent,
          ),
        if (map[key]["upperLimit"] != -1)
          Container(
            height: 40,
            child: buildBar(actualValue, map[key]["upperLimit"]),
          ),
      ],
    );
  }

  getBackgroundColour(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }
    if (map[key]["rangeMin"] > actualValue) {
      return Colors.lightBlue;
    } else if (map[key]["upperLimit"] >= actualValue ||
        map[key]["upperLimit"] == -1) {
      return Colors.lightGreen;
    }
    return Colors.redAccent;
  }

  getIcon(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    Color iconColor = getBackgroundColour(key, actualValue);

    if (map[key]["rangeMin"] > actualValue) {
      return Icon(
        Icons.radio_button_unchecked,
        color: iconColor,
      );
    } else if (map[key]["upperLimit"] >= actualValue ||
        map[key]["upperLimit"] == -1) {
      return Icon(
        Icons.check_circle_outline,
        color: iconColor,
      );
    }
    return Icon(
      Icons.do_not_disturb_alt,
      color: iconColor,
    );
  }

  buildIcon(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }

    return IconButton(
      icon: getIcon(key, actualValue),
      iconSize: 80,
    );
  }

  buildRange(String key) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (map.containsKey(key)) {
      if (map[key]["rangeMin"] == map[key]["rangeMax"]) {
        return Text(
          "RDI: ${map[key]["rangeMin"]} ${DBProvider.units[key]}",
          style: const TextStyle(fontSize: 18.0),
        );
      } else {
        return Text(
          "RDI: ${map[key]["rangeMin"]} - ${map[key]["rangeMax"]} ${DBProvider.units[key]}",
          style: const TextStyle(fontSize: 18.0),
        );
      }
    }
    return SizedBox.shrink();
  }

  buildText(String key, String item) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (map.containsKey(key)) {
      if (map[key][item] == -1) {
        return Text(
          "Max: ? ${DBProvider.units[key]}",
          style: const TextStyle(fontSize: 18.0),
        );
      }
      return Text(
        "Max: ${map[key][item]} ${DBProvider.units[key]}",
        style: const TextStyle(fontSize: 18.0),
      );
    }
    return SizedBox.shrink();
  }
}
