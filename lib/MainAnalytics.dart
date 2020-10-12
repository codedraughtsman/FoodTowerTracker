import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:foodtowertracker/ManagerPortions.dart';

import 'AddPortionSelectFood.dart';
import 'AnalyticsNutrientList.dart';
import 'EULA_Page.dart';
import 'TowerPageTodayOnly.dart';

class MainAnalytics extends StatefulWidget {
  @override
  _MainAnalyticsState createState() => _MainAnalyticsState();
}

class _MainAnalyticsState extends State<MainAnalytics> {
  @override
  Widget build(BuildContext context) {
    var items = <Widget>[
      TowerPageTodayOnly(),
      AnalyticsNutrientList(),
//      AnalyticsGraph(),
      ManagerPortions(),
      AddPortionSelectFood(
        isManager: true,
      ),
      EULA_Page(),
    ];
    return Scaffold(
      body: new Swiper(
        itemBuilder: (BuildContext context, int index) {
          return items[index];
        },
        itemCount: items.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPortionSelectFood()),
          );
        },
        tooltip: 'Add portion of food',
        child: const Icon(Icons.add),
      ),
    );
  }
}
