import 'package:flutter/material.dart';
import 'package:foodtowertracker/Tower.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class TowerPageTodayOnlyState extends State<TowerPageTodayOnly> {
  String dropdownValue = "totalEnergy";
  SelectBloc bloc;
  @override
  void initState() {
    super.initState();

    this.bloc = SelectBloc(
      query: DBProvider.getDailyTotals(),
      verbose: true,
      database: DBProvider.db,
      where:
          "portions.date = " + DBProvider.dateFormatter.format(DateTime.now()),
      reactive: true,
    );
  }

  void updateValue(String newValue) {
    setState(() {
      dropdownValue = newValue;
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
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                updateValue(newValue);
              },
              items: snapshot.data[0].keys
                  .map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            FlatButton(
              child: Text(
                snapshot.data[0][dropdownValue].toString() +
                    " " +
                    ((dropdownValue == "totalEnergy" ||
                            dropdownValue == "energy")
                        ? "kj"
                        : "grams"),
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
                Tower(constraints.maxWidth, constraints.maxHeight,
                    DateTime.now(), dropdownValue),
          ),
        ),
      ),
    );
  }
}

class TowerPageTodayOnly extends StatefulWidget {
  @override
  TowerPageTodayOnlyState createState() => TowerPageTodayOnlyState();
}
