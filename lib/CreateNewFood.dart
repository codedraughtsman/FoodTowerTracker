import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodtowertracker/DataBase.dart';
import 'package:foodtowertracker/data/JsonHolder.dart';

class CreateNewFood extends StatefulWidget {
  JsonHolder defaultFood;
  bool creatingNewFood = false;
  CreateNewFood({this.defaultFood}) {
    if (defaultFood == null) {
      defaultFood = JsonHolder.makePortion();
      creatingNewFood = true;
    }
  }
  @override
  _CreateNewFoodState createState() => _CreateNewFoodState();
}

class _CreateNewFoodState extends State<CreateNewFood> {
//  final _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> _mappedData = Map<String, String>();

  _createFood() {
//    DBProvider.newFoodEntry();
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      log("map is ${_mappedData}");
      if (widget.creatingNewFood) {
        log("saving food");
        DBProvider.saveFood(JsonHolder(_mappedData));
      } else {
        log("updating food");
        DBProvider.updateFood(JsonHolder(_mappedData));
      }
      _showDialog(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("food is ${widget.defaultFood} map is: ${widget.defaultFood.json}");
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a new food'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "save",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _createFood,
          ),
        ],
      ),
      body: Container(
        child: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
//                  TextFormField(
//                    decoration: InputDecoration(labelText: 'Food name'),
//                    validator: (value) {
//                      if (value.isEmpty) {
//                        return 'Please enter the food\'s name';
//                      }
//                    },
//                    onSaved: (val) => setState(() => _mappedData.update(
//                        "FoodName", (value) => val,
//                        ifAbsent: () => val)),
//                  ),
                  for (String key in widget.defaultFood.json.keys)
                    _buildFormEntryBox(key),
//                  Container(
//                      padding: const EdgeInsets.symmetric(
//                          vertical: 16.0, horizontal: 16.0),
//                      child: RaisedButton(
//                          onPressed: () {
//                            final form = _formKey.currentState;
//                            if (form.validate()) {
//                              form.save();
//                              log("map is ${_mappedData}");
//                              Navigator.pop(context);
//                              _showDialog(context);
//                            }
//                          },
//                          child: Text('Save'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildFormEntryBox(String key) {
    if (key == "foodId") {
      //hack to not show foodId.
      return Container();
      return Text("foodId: ${widget.defaultFood.getAsString(key)}");
    }
    return TextFormField(
      keyboardType: (widget.defaultFood.json[key] is num)
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(labelText: key),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a value for ${key}';
        }
      },
      initialValue: widget.defaultFood.getAsString(key),
      onSaved: (val) => setState(
          () => _mappedData.update(key, (value) => val, ifAbsent: () => val)),
    );
  }

  _showDialog(BuildContext context) {
//    Scaffold.of(context)
//        .showSnackBar(SnackBar(content: Text('Submitted form')));
  }
}
