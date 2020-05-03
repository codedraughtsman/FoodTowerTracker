import 'package:flutter/material.dart';
import 'package:foodtowertracker/Tower.dart';

class TowerPageTodayOnlyState extends State<TowerPageTodayOnly> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Today"),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "settings",
              style: TextStyle(color: Colors.white),
            ),
//            onPressed: _onAdd,
          ),
        ],
      ),
      body: Padding(
        padding: new EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Tower(
              constraints.maxWidth, constraints.maxHeight, DateTime.now()),
        ),
      ),
    );
  }
}

class TowerPageTodayOnly extends StatefulWidget {
  @override
  TowerPageTodayOnlyState createState() => TowerPageTodayOnlyState();
}
