import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/HelpButton.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:foodtowertracker/Tower.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class TowerPageTodayOnlyState extends State<TowerPageTodayOnly> {
  SelectBloc bloc;
  SelectBloc popupBloc;
  @override
  void initState() {
    super.initState();

    this.bloc = SelectBloc(
      query: DBProvider.getDailyTotals(dateTime: DateTime.now()),
      database: DBProvider.db,
      where:
          'portions.date =  "${DBProvider.dateFormatter.format(DateTime.now())}"',
      reactive: true,
    );

    this.popupBloc = SelectBloc(
      query: "select settings.value from settings",
      verbose: true,
      database: DBProvider.db,
      reactive: true,
      where: "settings.name = EulaIsSigned",
    );
    this.popupBloc.items.listen((change) {
      log("database has changed ${change}");

      var EulaIsSigned = change[0]["value"];
      log("so EulaIsSigned is ${EulaIsSigned}, ${(EulaIsSigned.runtimeType)}");
      if (EulaIsSigned != "1") {
        showAlertDialog(context);
        log("showing popup now");
      }
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        DBProvider.db.update(
            table: "settings",
            row: {"value": "1"},
            where: "name= 'EulaIsSigned'");
        return Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: SingleChildScrollView(
        child: Text(DBProvider.StringEULA_Text),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
            HelpButton("Help - Nutrient Tower view",
                """Here you can see the composition of what you have eaten today.

The x axis is the amount of nutrients in 100 grams of the food.

Each food’s y height is the total amount of nutrients from that food. 

Thus the sum of all the food’s y heights is the total amount of nutrients eaten today.
"""),
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
