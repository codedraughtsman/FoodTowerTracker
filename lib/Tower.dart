import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class Tower extends StatefulWidget {
  double ySize, xSize;
  DateTime _dateTime;
  String towerTypeString;

  Tower(this.xSize, this.ySize, this._dateTime, this.towerTypeString) {}
  @override
  _TowerState createState() =>
      _TowerState(xSize, ySize, _dateTime, towerTypeString);
}

class _TowerState extends State<Tower> {
  double ySize;
  double xSize;
  DateTime _dateTime;
  String towerTypeString;

  _TowerState(this.xSize, this.ySize, this._dateTime, this.towerTypeString) {}
  SelectBloc bloc;

  @override
  void initState() {
    super.initState();

    this.bloc = SelectBloc(
        query: DBProvider.getDailyFoodSumsQuery(_dateTime),
        verbose: true,
        database: DBProvider.db);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<List<Map>>(
      stream: bloc.items,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Center(
              child: Text("No data. Use the + in the appbar to insert an item"),
            );
          }
          return Container(
            child: LayoutBuilder(
              builder: (context, constraints) {
                xSize = constraints.maxWidth;
                ySize = constraints.maxWidth;
                return Column(
                  children: _towerBlocks(
                    context,
                    snapshot,
                  ),
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                );
              },
            ),
          );
        } else {
          // the select query is still running
          return CircularProgressIndicator();
        }
      },
    );
  }

  _towerBlocks(BuildContext context, AsyncSnapshot snapshot) {
    var portions = <PortionEntry>[];

    for (var s in snapshot.data) {
      portions.add(PortionEntry.fromMap(s));
    }

    //sort portions by max y value
    portions.sort((a, b) => a
        .getTotalValueInMeasure(towerTypeString)
        .compareTo(b.getTotalValueInMeasure(towerTypeString)));

    double maxXValue = 0.0;
    portions.forEach((PortionEntry portion) {
      double value = portion.getMappedValue(towerTypeString) *
          100 /
          portion.getMappedValue("measure");
      maxXValue = math.max(value, maxXValue);
    });

    var towerBlocks = List<Widget>();
    portions.forEach((PortionEntry portion) {
      double valuePer100g = portion.getMappedValue(towerTypeString) *
          100 /
          portion.getMappedValue("measure");

      towerBlocks.add(
        Expanded(
          flex: portion.getTotalValueInMeasure(towerTypeString).toInt(),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: valuePer100g.toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.primaries[
                            portion.foodId % Colors.primaries.length],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (maxXValue - valuePer100g).toInt(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,

//                direction: Axis.vertical,
                children: <Widget>[
                  Container(
//                    color: Colors.blueGrey,
                    child: Text(
                      portion.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
//                  Expanded(
////                    flex: maxXValue.toInt(),
//                    child: Text(
//                      portion.name,
//                      overflow: TextOverflow.ellipsis,
//                      textAlign: TextAlign.end,
//                    ),
//                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    return towerBlocks;
  }
}
