import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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
    printWrapped("weeklyBloc  ${weeklyBloc.toString()}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Nutrients'),
          actions: <Widget>[
            FlatButton(
              child: const Text(
                "settings",
                style: TextStyle(color: Colors.white),
              ),
//              onPressed: _createFood,
            ),
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
                    return _buildBody(context, snapshot, snapshotWeekly);
                  });
            }));
  }

  Widget _buildBody(context, snapshot, snapshotWeekly) {
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
              Map<String, dynamic> mappedWeekly = snapshotWeekly.data[0];
              log("key is $key");
              double value = double.parse(mapped[key].toString());
              double weeklyValue = double.parse(mappedWeekly[key].toString());
              return _buildRow(key, value, weeklyValue);
            }),
      );
    } else {
      // the select query is still running
      return FittedBox(
        fit: BoxFit.contain,
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildRow(String key, double value, double weeklyValue) {
    return ListTile(
      onTap: () {
        _onTap(key);
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FittedBox(
            child: Text(
              DBProvider.humanReadableNames[key],
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("Today: "),
              Text(
                DBProvider.doubleToStringConverter(value) +
                    " " +
                    DBProvider.getUnit(key),
                style: const TextStyle(fontSize: 18.0),
              ),
//              Text(
//                " of 200.0" + " " + DBProvider.getUnit(key),
//                style: const TextStyle(fontSize: 18.0),
//              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("For week: "),
              Text(
                DBProvider.doubleToStringConverter(weeklyValue) +
                    " " +
                    DBProvider.getUnit(key),
                style: const TextStyle(fontSize: 18.0),
              ),
//              Text(
//                " of 200.0" + " " + DBProvider.getUnit(key),
//                style: const TextStyle(fontSize: 18.0),
//              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
//              Text(
//                "Daily ",
//                style: const TextStyle(fontSize: 18.0),
//              ),
              buildIcon(key, value),
              Column(
                children: <Widget>[
                  buildRange(key),
                  buildText(key, "upperLimit"),
                ],
              ),
            ],
          ),
          buildProgressBar(key, value),
        ],
      ),
    );
  }

  buildProgressBar(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }
    double maxValue = map[key]["rangeMax"];
    if (map[key]["upperLimit"] != -1) {
      maxValue = math.max(maxValue, map[key]["upperLimit"]);
    }
    double rangeSize = map[key]["rangeMax"] - map[key]["rangeMin"];
    if (rangeSize == 0) {
      rangeSize = 5;
    }
    double endcap = 0;
    if (map[key]["upperLimit"] != -1) {
      endcap = math.max(
          map[key]["upperLimit"] * 0.05, actualValue - map[key]["upperLimit"]);
    }
    double scaleFactor = 100;
    return Container(
      height: 40,
      color: Colors.grey,
      child: Row(
        children: <Widget>[
          Expanded(
            //bar till start of range.
            flex: (actualValue * scaleFactor).toInt(),
            child: Container(color: Colors.blue),
          ),
          Expanded(
            //filler to the start of the range. May be 0.
            flex: ((map[key]["rangeMin"] - actualValue) * scaleFactor).toInt(),
            child: Container(color: Colors.grey),
          ),
          Expanded(
            //actual range
            flex: (rangeSize * scaleFactor).toInt(),
            child: Container(color: Colors.green),
          ),
          Expanded(
              //filler to max value.
              flex: ((maxValue - actualValue) * scaleFactor).toInt(),
              child: Container(color: Colors.grey)),
          Expanded(
              //endcap to show danger zone.
              flex: (endcap * scaleFactor).toInt(),
              child: Container(color: Colors.red)),
        ],
      ),
    );
  }

  getBackgroundColour(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }
    if (map[key]["rangeMin"] < actualValue) {
      return Colors.transparent;
    } else if (map[key]["upperLimit"] <= actualValue) {
      return Colors.redAccent;
    }
    return Colors.lightGreen;
  }

  buildIcon(String key, double actualValue) {
    var map = DBProvider.getFoodNutrientsLimitMap();
    if (!map.containsKey(key)) {
      return SizedBox.shrink();
    }
    if (map[key]["rangeMin"] > actualValue) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey,
      );
    } else if (map[key]["upperLimit"] <= actualValue &&
        map[key]["upperLimit"] != -1) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.purple,
      );
    }
    return Container(
      width: 80,
      height: 80,
      color: Colors.green,
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
