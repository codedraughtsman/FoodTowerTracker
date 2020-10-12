import 'package:flutter/material.dart';
import 'package:foodtowertracker/DataBase.dart';

class EULA_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
        actions: <Widget>[],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(DBProvider.StringEULA_Text),
        ),
      ),
    );
    ;
  }
}
