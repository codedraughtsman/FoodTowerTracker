import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class Tower extends StatefulWidget {
  DateTime _dateTime;
  String towerTypeString;

  Tower(this._dateTime, this.towerTypeString) {}
  @override
  _TowerState createState() => _TowerState(_dateTime, towerTypeString);
}

class _TowerState extends State<Tower> {
  DateTime _dateTime;
  String towerTypeString;
  var portions = <PortionEntry>[];
  double maxXValue = 0.0, maxYValue = 0.0;

  _TowerState(this._dateTime, this.towerTypeString) {}
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
              child: Text(
                  "No data for today. Use the + button to add a portion of food"),
            );
          }
          _updatePortions(snapshot);
          _updateMaxValues();
          return Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: SizedBox(
                          width: 20,
                          height: double.infinity,
                          child: buildYAxis(),
                        ),
//                        color: Colors.purple,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
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
                      ),
                    ],
                  ),
                ),
                Container(
                  child: SizedBox(
                    width: double.infinity,
                    height: 20,
                    child: buildXAxis(),
                  ),
//                  color: Colors.cyan,
                ),
              ],
            ),
          );
        } else {
          // the select query is still running
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget buildYAxis() {
    return Row(
      children: <Widget>[
        RotatedBox(
          quarterTurns: 3,
          child: Text("Total ${DBProvider.units[towerTypeString]} eaten today"),
        ),
      ],
    );
    return Column(
      children: <Widget>[
        for (int i = 0; i < maxYValue; i++)
//        if (i%100 ==0) {
          Expanded(
            flex: 1,
            child: Container(
              color: (i % 500 == 0) ? Colors.black : Colors.transparent,
              height: 5,
            ),
          )
//      },
      ],
    );
  }

  Widget buildXAxis() {
    return Column(
      children: <Widget>[
        RotatedBox(
          quarterTurns: 0,
          child: Text(
              "${DBProvider.units[towerTypeString]} per 100 grams of food"),
        ),
      ],
    );
    return Row(
      children: <Widget>[
        for (int i = 0; i < maxXValue; i++)
//        if (i%100 ==0) {
          Expanded(
            flex: 1,
            child: Container(
              color: (i % 100 == 0) ? Colors.black : Colors.transparent,
            ),
          )
//      },
      ],
    );
  }

  _updatePortions(AsyncSnapshot snapshot) {
    portions.clear();

    for (var s in snapshot.data) {
      portions.add(PortionEntry.fromMap(s));
    }

    //sort portions by max y value
    portions.sort((a, b) => a
        .getTotalValueInMeasure(towerTypeString)
        .compareTo(b.getTotalValueInMeasure(towerTypeString)));
  }

  _updateMaxValues() {
    maxXValue = 0.0;
    maxYValue = 0.0;
    portions.forEach((PortionEntry portion) {
      double value = portion.getMappedValue(towerTypeString) *
          100 /
          portion.getMappedValue("measure");
      maxXValue = math.max(value, maxXValue);
      maxYValue += portion.getMappedValue(towerTypeString);
    });
  }

  _towerBlocks(BuildContext context, AsyncSnapshot snapshot) {
    var towerBlocks = List<Widget>();
    portions.forEach((PortionEntry portion) {
      double valuePer100g = portion.getMappedValue(towerTypeString) *
          100 /
          portion.getMappedValue("measure");
      double scaleFactor = 1000.0;
      towerBlocks.add(
        Expanded(
          flex: (portion.getTotalValueInMeasure(towerTypeString) * scaleFactor)
              .toInt(),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: (valuePer100g * scaleFactor).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.primaries[
                            portion.foodId % Colors.primaries.length],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ((maxXValue - valuePer100g) * scaleFactor).toInt(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    portion.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    minFontSize: 0,
                    stepGranularity: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return towerBlocks;
  }
}
