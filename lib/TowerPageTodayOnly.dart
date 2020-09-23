import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:foodtowertracker/Tower.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class TowerPageTodayOnlyState extends State<TowerPageTodayOnly> {
  SelectBloc bloc;
  @override
  void initState() {
    super.initState();

    this.bloc = SelectBloc(
      query: DBProvider.getDailyTotals(dateTime: DateTime.now()),
      verbose: true,
      database: DBProvider.db,
      where:
          'portions.date =  "${DBProvider.dateFormatter.format(DateTime.now())}"',
      reactive: true,
    );
  }

  void updateValue(String newValue) {
    setState(() {
      widget.dropdownValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map>>(
      stream: bloc.items,
      builder: (context, snapshot) => Scaffold(
        appBar: new AppBar(
          title: new Text("Today"),
          actions: <Widget>[
            FlatButton(
              child: Text(
                DBProvider.humanReadableNames[widget.dropdownValue],
                style: TextStyle(color: Colors.white),
              ),
            ),
//            DropdownButton<String>(
//              value: widget.dropdownValue,
//              icon: Icon(Icons.arrow_downward),
//              iconSize: 24,
//              elevation: 16,
//              style: TextStyle(color: Colors.deepPurple),
//              underline: Container(
//                height: 2,
//                color: Colors.deepPurpleAccent,
//              ),
//              onChanged: (String newValue) {
//                updateValue(newValue);
//              },
//              items: snapshot.data[0].keys
//                  .map<DropdownMenuItem<String>>((dynamic value) {
//                return DropdownMenuItem<String>(
//                  value: value,
//                  child: Text(value),
//                );
//              }).toList(),
//            ),

            FlatButton(
              child: Text(
                (() {
                  if (snapshot.hasData) {
                    double value = 0;
                    if (snapshot.data.length > 0) {
                      value = PortionEntry.fromMap(snapshot.data[0])
                          .getMappedValue(widget.dropdownValue);
                    }
                    log("tower data length is ${snapshot.data.length}");
                    return "${DBProvider.doubleToStringConverter(value)} ${DBProvider.units[widget.dropdownValue]}";
                  } else {
                    return "0 ${DBProvider.units[widget.dropdownValue]}";
                  }
                }()),
                style: TextStyle(color: Colors.white),
              ),
            ),
//            FlatButton(
//              child: const Text(
//                "settings",
//                style: TextStyle(color: Colors.white),
//              ),
//            onPressed: _onAdd,
//            ),
          ],
        ),
        body: Padding(
          padding: new EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                Tower(DateTime.now(), widget.dropdownValue),
          ),
        ),
      ),
    );
  }
}

class TowerPageTodayOnly extends StatefulWidget {
  String dropdownValue = "energy";
  TowerPageTodayOnly({this.dropdownValue = "energy"}) {
    log("tower page today is ${dropdownValue}");
  }

  @override
  TowerPageTodayOnlyState createState() => TowerPageTodayOnlyState();
}
