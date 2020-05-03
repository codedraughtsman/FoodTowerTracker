import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/FoodEntry.dart';
import 'package:json_to_form/json_schema.dart';

class CreateNewFood extends StatefulWidget {
  @override
  _CreateNewFoodState createState() => _CreateNewFoodState();
}

class _CreateNewFoodState extends State<CreateNewFood> {
  var _newFoodEntry;

  _createFood(data) {
//    DBProvider.newFoodEntry();
    print(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _newFoodEntry = FoodEntry();
    log("food is $_newFoodEntry ${_newFoodEntry.toMap()}");
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a new food'),
        actions: <Widget>[
//          FlatButton(
//            child: const Text("create"),
//            onPressed: _createFood,
//          ),
        ],
      ),
      body: Container(
          child: JsonSchema(
//        decorations: decorations,
        formMap: _newFoodEntry.toMap(),
//        onChanged: (dynamic response) {
//          this.response = response;
//        },
        actionSave: (data) {
          _createFood(data);
        },
        buttonSave: new Container(
          height: 40.0,
          color: Colors.blueAccent,
          child: Center(
            child: Text("Login",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      )),
    );
  }
}
