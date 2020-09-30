import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtowertracker/HelpButton.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class SelectableItem<T> {
  T data;
  bool isSelected;
  SelectableItem(this.data, {this.isSelected = false}) {}
}

class ManagerPortions extends StatefulWidget {
  @override
  ManagerPortions_State createState() => ManagerPortions_State();
}

class ManagerPortions_State extends State<ManagerPortions> {
  SelectBloc bloc;
  var selectedItems = <SelectableItem<PortionEntry>>[];

  void _deleteSelectedItems() {
    //todo make a copy just incase deleting them triggers an update.
    var unselectedItems = <SelectableItem<PortionEntry>>[];
    for (var item in selectedItems) {
      if (item.isSelected) {
        log("deleting ${item.data.name}");
        try {
          DBProvider.db
              .delete(
                  table: DBProvider.tablePortionsName,
                  where: "portionId = ${item.data.portionId}",
                  verbose: true)
              .then((value) {
            bloc.refresh();
          });
        } catch (e) {
          rethrow;
        }
        ;
      } else {
        unselectedItems.add(item);
      }
    }
    selectedItems = unselectedItems;
  }

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
            child: Text(
              "delete",
              style: TextStyle(
                  color: selectedItems.any((element) => element.isSelected)
                      ? Colors.white
                      : Colors.grey),
            ),
            onPressed: _deleteSelectedItems,
          ),
          HelpButton("Help - Manage Portions",
              """Here you can see all the portions of food you have eaten. 

Hold down an entry to select it and use the delete button to remove all selected portions.
"""),
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
      return Padding(
        padding: new EdgeInsets.all(16.0),
        child: Center(
          child: Text(
              "No portions of food have been entered yet. Use the + button to add a portion of food"),
        ),
      );
    }
    log("rebuilding entire view");

    return ListView.separated(
      padding: EdgeInsets.only(top: 16.0),
      itemCount: snapshot.data.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (context, index) {
        var portionEntry = PortionEntry.fromMap(snapshot.data[index]);
        selectedItems.add(SelectableItem<PortionEntry>(portionEntry));
        log("adding ${portionEntry.name} at $index");

        return GestureDetector(
          onLongPress: () {
            setState(() {
              log("long press for ${selectedItems[index]}");
              selectedItems[index].isSelected =
                  !selectedItems[index].isSelected;
            });
          },
          onTap: () {
            log("ontap");
            if (selectedItems.contains((element) => element.isSeleted)) {
              log("is selected");
              setState(() {
                selectedItems[index].isSelected =
                    !selectedItems[index].isSelected;
              });
            }
          },
          child: _buildRow(portionEntry, index),
        );
      },
    );
  }

  _buildRow(PortionEntry portionEntry, int index) {
    final biggerFont = const TextStyle(fontSize: 18.0);

    return Container(
      color: selectedItems[index].isSelected ? Colors.blue[100] : Colors.white,
      child: ListTile(
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
        selected: true,
        onTap: () {
          _listItemOnTap(portionEntry);
        },
      ),
    );
  }

  _listItemOnTap(PortionEntry portionEntry) {}
}
