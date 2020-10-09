import 'package:flutter/material.dart';
import 'package:foodtowertracker/LoadingScreen.dart';
import 'package:foodtowertracker/MainAnalytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new MainAnalytics(),
      },
      home: LoadingScreen(),
//      home: TowerPageTodayOnly(),
    );
  }
}
