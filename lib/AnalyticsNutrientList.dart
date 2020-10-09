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
      reactive: true,
      database: DBProvider.db,
    );
    printWrapped(bloc.toString());
    this.weeklyBloc = SelectBloc(
      query: DBProvider.getWeeklyTotals(dateTime: DateTime.now()),
      table: "foodData",
      verbose: true,
      reactive: true,
      database: DBProvider.db,
    );
    this.blocNutrientLevels = SelectBloc(
        table: "nutrientSettings",
        columns: "*",
        verbose: true,
        reactive: true,
        database: DBProvider.db,
        where: "showNutrient = 1");
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

Use the "set nutrient" button to set the RDI and maximum limits for the nutrients. You can also hide the nutrients as well.

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
    log("snapshot snapshotNutrientLevels data : ${snapshotNutrientLevels.data}");
    if (snapshot.hasData) {
      if (snapshot.data.length == 0) {
        return Padding(
          padding: new EdgeInsets.all(16.0),
          child: Text(
              "No food entries for today. Add entries using the '+' button"),
        );
      }
      log("snapshot data: ${snapshot.data}");
      var keys = [];
      for (var item in snapshotNutrientLevels.data) {
        keys.add(item["name"]);
      }

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
              var nutrientsData = null;
              for (var nutrient in snapshotNutrientLevels.data) {
                if (nutrient["name"] == key) {
                  nutrientsData = nutrient;
                  break;
                }
              }
              if (nutrientsData == null) {
                return ListTile(
                  title: Text(key),
                );
              }
              return _buildRow(key, value, weeklyValue, nutrientsData);
            }),
      );
    } else {
      // the select query is still running

    }
  }

  Widget _buildRow(
      String key, double value, double weeklyValue, nutrientsData) {
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
              nutrientsData["longName"],
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (nutrientsData["showRDI"] != 0 ||
                  nutrientsData["showLimit"] != 0)
                buildIcon(value, nutrientsData),
              if (nutrientsData["showRDI"] == 0 &&
                  nutrientsData["showLimit"] == 0)
                Spacer(),
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
                            nutrientsData["unit"],
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                  if (nutrientsData["showRDI"] == 1)
                    buildRDI_RangeText(nutrientsData),
                  if (nutrientsData["showLimit"] == 1)
                    buildMaxLimitText(nutrientsData),
                ],
              )
            ],
          ),
          Container(
            height: 10,
            color: Colors.transparent,
          ),
          buildProgressBar(key, value, nutrientsData),
        ],
      ),
    );
  }

  buildBar(double value, nutrientsData, {isMaxBar = false}) {
    double lowerLimit = double.parse(nutrientsData["RDI_Min"].toString()),
        upperLimit = double.parse(nutrientsData["RDI_Max"].toString());
    Color rangeColour = Colors.green;
    Color endCapColour = Colors.black12;

    double scaleFactor = 10000;
    if (isMaxBar) {
      // A lower limit is not set.
      // It is a max limit bar.
      lowerLimit = double.parse(nutrientsData["maxLimit"].toString());
      upperLimit = lowerLimit + lowerLimit * 0.1;
      rangeColour = Colors.red;
      endCapColour = rangeColour;
    }
    if (upperLimit == lowerLimit) {
      //the two values need a slight difference to show up.
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

  buildRDI(actualValue, nutrientsData) {
    if (nutrientsData["showRDI"] == 0 ||
        (nutrientsData["RDI_Min"] == 0 && nutrientsData["RDI_Max"] == 0)) {
      return SizedBox.shrink();
    }
    return Column(
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
          child: buildBar(actualValue, nutrientsData),
        ),
        Container(
          height: 10,
          color: Colors.transparent,
        ),
      ],
    );
  }

  buildMaxLimit(
    actualValue,
    nutrientsData,
  ) {
    if (nutrientsData["showLimit"] == 0 || nutrientsData["maxLimit"] == 0) {
      return SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        Text(
          "Progress on Daily Maximum",
          style: TextStyle(fontSize: 14),
        ),
        Container(
          height: 2,
          color: Colors.transparent,
        ),
        Container(
          height: 40,
          child: buildBar(actualValue, nutrientsData, isMaxBar: true),
        ),
      ],
    );
  }

  buildProgressBar(String key, double actualValue, nutrientsData) {
    return
//      color: Colors.grey,
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildRDI(actualValue, nutrientsData),
        buildMaxLimit(actualValue, nutrientsData)
      ],
    );
  }

  getBackgroundColour(double actualValue, nutrientsData) {
    double RDI_Min = double.parse(nutrientsData["RDI_Min"].toString()),
        RDI_Max = double.parse(nutrientsData["RDI_Max"].toString()),
        upperLimit = double.parse(nutrientsData["maxLimit"].toString());
    if (RDI_Min > actualValue) {
      return Colors.lightBlue;
    } else if (upperLimit >= actualValue || nutrientsData["showLimit"] == 0) {
      return Colors.lightGreen;
    }
    return Colors.redAccent;
  }

  getIcon(double actualValue, nutrientsData) {
    Color iconColor = getBackgroundColour(actualValue, nutrientsData);
    double RDI_Min = double.parse(nutrientsData["RDI_Min"].toString()),
        RDI_Max = double.parse(nutrientsData["RDI_Max"].toString()),
        upperLimit = double.parse(nutrientsData["maxLimit"].toString());
    if (RDI_Min > actualValue) {
      return Icon(
        Icons.radio_button_unchecked,
        color: iconColor,
      );
    } else if (upperLimit >= actualValue || nutrientsData["showLimit"] == 0) {
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

  buildIcon(double actualValue, nutrientsData) {
    return IconButton(
      icon: getIcon(actualValue, nutrientsData),
      iconSize: 80,
    );
  }

  buildRDI_RangeText(nutrientsData) {
    var minValue = nutrientsData["RDI_Min"],
        maxValue = nutrientsData["RDI_Max"];
    var unit = nutrientsData["unit"];
    if (minValue == maxValue) {
      return Text(
        "RDI: ${minValue} ${unit}",
        style: const TextStyle(fontSize: 18.0),
      );
    } else {
      return Text(
        "RDI: ${minValue} - ${maxValue} ${unit}",
        style: const TextStyle(fontSize: 18.0),
      );
    }
  }

  buildMaxLimitText(nutrientsData) {
    if (nutrientsData["maxLimit"] == -1) {
      return Text(
        "Max: ? ${nutrientsData["unit"]}",
        style: const TextStyle(fontSize: 18.0),
      );
    }
    return Text(
      "Max: ${nutrientsData["maxLimit"]} ${nutrientsData["unit"]}",
      style: const TextStyle(fontSize: 18.0),
    );
  }
}
