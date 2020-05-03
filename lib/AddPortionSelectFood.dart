import 'dart:developer'; //debug printing

import 'package:flutter/material.dart';
import 'package:foodtowertracker/AddPortionEnterGrams.dart';
import 'package:foodtowertracker/CreateNewFood.dart';
import 'package:foodtowertracker/DataBase.dart';
import 'package:foodtowertracker/FoodEntry.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class AddPortionSelectFoodState extends State<AddPortionSelectFood> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  SelectBloc bloc;

  @override
  void initState() {
    super.initState();
    this.bloc = SelectBloc(
        columns: '''* ''',
        table: "foodData",
        verbose: true,
        orderBy: "name",
        database: DBProvider.db);
    log(bloc.toString());
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Add 20 lines from here...
        builder: (BuildContext context) {},
      ),
    );
  }

  _createFood() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewFood()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add a portion of'),
          actions: <Widget>[
            FlatButton(
              child: const Text(
                "create food",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _createFood,
            ),
          ],
        ),
        body: StreamBuilder<List<Map>>(
            stream: bloc.items,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return _buildBody(context, snapshot);
            }));
  }

  _onSearchFieldChanged(String newSearchTerm) {
//    this.bloc = SelectBloc(
//      columns: '''* ''',
//      table: "foodData",
//      verbose: true,
//      database: DBProvider.db,
//      where: '''name like "%${newSearchTerm}%"''',
//    );
    bloc.where = '''name like "%${newSearchTerm}%"''';
    log("updated bloc to ${bloc.where.toString()}");
    log("bloc items ${bloc.items.length}");
    bloc.refresh();
  }

  Widget _buildBody(context, snapshot) {
    if (snapshot.hasData) {
      var widgets = <Widget>[
        TextField(
          autofocus: true,
          decoration: InputDecoration(
//                  border: InputBorder.none,

            hintText: 'Enter a search term',
          ),
          onChanged: _onSearchFieldChanged,
        ),
      ];
      if (snapshot.data.length == 0) {
        widgets.add(
          Center(
            child: Text("no item matches your search"),
          ),
        );
      } else {
        widgets.add(
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.only(top: 16.0),
                itemCount: snapshot.data.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  var foodEntry = FoodEntry.fromMap(snapshot.data[index]);
                  return _buildRow(foodEntry);
                }),
          ),
        );
      }
      return Padding(
        padding: new EdgeInsets.all(16.0),
        child: Column(
          children: widgets,
        ),
      );
    } else {
      // the select query is still running
      return FittedBox(
        fit: BoxFit.contain,
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildRow(foodEntry) {
    return ListTile(
      title: Text(
        foodEntry.name,
        style: _biggerFont,
      ),
      trailing: Text(
        foodEntry.energy.toString() + " kj",
        style: _biggerFont,
      ),
      onTap: () {
        _listItemOnTap(foodEntry);
      },
    );
  }

  void _listItemOnTap(food) {
    log("you tapped " + food.name);
    //navigate to enter amount of food.
//    Navigator.of(context).push(
//      MaterialPageRoute<void>(
//        // Add 20 lines from here...
//        builder: (BuildContext context) {
//          return AddPortionEnterGramsState();
//        },
//      ),
//    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPortionEnterGrams(food)),
    );
  }
}

class AddPortionSelectFood extends StatefulWidget {
  @override
  AddPortionSelectFoodState createState() => AddPortionSelectFoodState();
}
