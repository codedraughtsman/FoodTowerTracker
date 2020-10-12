import 'dart:developer';

import 'package:flutter/material.dart';

import 'DataBase.dart';

class LoadingScreen extends StatefulWidget {
  var future = null;
  LoadingScreen() {}
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
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
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.future == null) {
      try {
        widget.future = DBProvider.db.init(
            path: "FoodTowerTracker.db",
            fromAsset: "assets/data.sqlite",
            verbose: true);
      } catch (e) {
        throw ("Error initializing the database: ${e.message.toString()}");
      }
      widget.future.then((value) {
        var showEULA = true;
        if (showEULA) {
//          return Navigator.push(
//              context, MaterialPageRoute(builder: (context) => EULA_Popup()));
          showAlertDialog(context);
        } else {
          return Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        }
      });
    }
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        log("creating base load");
        return Scaffold(
          appBar: AppBar(
            title: Text("Minimalist food and nutrition tracker"),
            actions: <Widget>[],
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Text("Loading data:"),
                FittedBox(
                  fit: BoxFit.contain,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
