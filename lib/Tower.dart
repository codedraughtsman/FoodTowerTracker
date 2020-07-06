import 'dart:developer';
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
//            color: Colors.cyan,
            child: Column(
              children: _towerBlocks(
                context,
                snapshot,
              ),
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
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
    double totalYValue = 0.0;
    var portions = <PortionEntry>[];
    for (var s in snapshot.data) {
      //log(s);
      portions.add(PortionEntry.fromMap(s));
    }

    portions.forEach((PortionEntry portion) {
      var value = portion.getMappedValue(towerTypeString);
      if (value == null) {
        value = 0;
      }

      totalYValue += value;
    });

    int maxXValue = 0;
    portions.forEach((PortionEntry portion) {
      var value = portion.getMappedValue(towerTypeString);
      if (value == null) {
        value = 0;
      }
      maxXValue = math.max(value, maxXValue);
    });

    double scaleFactorY = ySize / totalYValue;
    double scaleFactorX = xSize / maxXValue.toDouble();

    var towerBlocks = List<Widget>();

    portions.forEach((PortionEntry portion) {
      towerBlocks.add(_buildTowerBlock(portion, scaleFactorY, scaleFactorX));
    });
    return towerBlocks;
  }

  Widget _buildTowerBlock(
      PortionEntry portion, double yScaleFactor, double xScaleFactor) {
//    log("inside block build portion.energy * xScaleFactor is ${portion.energy * xScaleFactor}");
    int yValue = portion.getMappedValue(towerTypeString);
    log("yValue is: " + yValue.toString() + " for " + towerTypeString);
    if (yValue == null) {
      yValue = 0;
    }

    return SizedBox(
      height: yValue.toDouble() * yScaleFactor,
      width: xSize,
      child: Stack(
        children: <Widget>[
          Container(
            height: yValue.toDouble() * yScaleFactor,
            width: yValue * xScaleFactor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.primaries[portion.foodId % Colors.primaries.length],
            ),
          ),
          SizedBox(
            height: yValue * yScaleFactor,
            width: xSize,
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: Text(
                    portion.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
