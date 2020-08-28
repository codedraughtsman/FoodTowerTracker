import 'dart:developer';

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
              Text(
                " of 200.0" + " " + DBProvider.getUnit(key),
                style: const TextStyle(fontSize: 18.0),
              ),
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
              Text(
                " of 200.0" + " " + DBProvider.getUnit(key),
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
