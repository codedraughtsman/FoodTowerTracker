import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/DataBase.dart';
import 'package:foodtowertracker/MainAnalytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DBProvider.db
      .init(
          path: "FoodTowerTracker.db",
          fromAsset: "assets/data.sqlite",
          verbose: true)
      .then(
    (value) {
      runApp(MyApp());
    },
  ).catchError((e) {
    throw ("Error initializing the database: ${e.message.toString()}");
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log("inside MyApp: running main app. database should be initialised by now");
    log("inside myApp: DBProvider.database.isReady ${DBProvider.db.isReady}");
    // DBProvider.initDB();
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new MainAnalytics(),
      },
      home: MainAnalytics(),
//      home: TowerPageTodayOnly(),
    );
  }
}
