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
              child: Text("No data. Use the + in the appbar to insert an item"),
            );
          }
          return Container(
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
                children: <Widget>[
                  Container(
                    child: Expanded(
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
                  ),
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
