import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class ManagerPortions extends StatefulWidget {
  @override
  ManagerPortions_State createState() => ManagerPortions_State();
}

class ManagerPortions_State extends State<ManagerPortions> {
  SelectBloc bloc;

  @override
  void initState() {
    super.initState();
    this.bloc = SelectBloc(
        columns: '''portions.*, foodData.* ''',
        table: "portions",
        joinTable: "foodData",
        joinOn: "portions.foodId = foodData.foodId",
        orderBy: "portions.date DESC, portions.time DESC",
        verbose: true,
//        orderBy: "name",
        database: DBProvider.db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Portions'),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "actions",
              style: TextStyle(color: Colors.white),
            ),
//            onPressed: _createFood,
          ),
        ],
      ),
      body: StreamBuilder<List<Map>>(
        stream: bloc.items,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return _buildBody(context, snapshot);
        },
      ),
    );
  }

  _buildBody(BuildContext context, AsyncSnapshot snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    if (snapshot.data.length == 0) {
      return Text("please add some portion entries");
    }
    log(snapshot.data.toString());
    return ListView.separated(
        padding: EdgeInsets.only(top: 16.0),
        itemCount: snapshot.data.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          var portionEntry = PortionEntry.fromMap(snapshot.data[index]);
          return _buildRow(portionEntry);
        });
  }

  _buildRow(PortionEntry portionEntry) {
    final biggerFont = const TextStyle(fontSize: 18.0);

    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text(portionEntry.date), Text(portionEntry.time)],
      ),
      title: Text(
        portionEntry.name,
        style: biggerFont,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            portionEntry.totalEnergy.toString() + " kj",
            style: biggerFont,
          ),
          Text(portionEntry.grams.toString() + " grams")
        ],
      ),
      onTap: () {
        _listItemOnTap(portionEntry);
      },
    );
  }

  _listItemOnTap(PortionEntry portionEntry) {}
}
