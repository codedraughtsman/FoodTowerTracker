import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:foodtowertracker/AggregatedData.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';

class AnalyticsGraph extends StatefulWidget {
  @override
  _AnalyticsGraphState createState() => _AnalyticsGraphState();
}

class _AnalyticsGraphState extends State<AnalyticsGraph> {
  SelectBloc bloc;

  @override
  void initState() {
    this.bloc = SelectBloc(
      query: DBProvider.getDailyTotals(),
      verbose: true,
      database: DBProvider.db,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Current Week"),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "settings",
              style: TextStyle(color: Colors.white),
            ),
//            onPressed: _onAdd,
          ),
        ],
      ),
      body: StreamBuilder<List<Map>>(
        stream: bloc.items,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return _buildChartWidget(snapshot);
        },
      ),
    );
  }

  _buildChartWidget(AsyncSnapshot snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    var data = <AggregatedData>[];
    for (var row in snapshot.data) {
      data.add(AggregatedData.fromMap(row));
    }
    var series = <charts.Series<AggregatedData, String>>[
      charts.Series(
        id: 'Clicks',
        domainFn: (AggregatedData data, _) => data.date,
        measureFn: (AggregatedData data, _) => data.energy,
//        colorFn: (AggregatedData data, _) => clickData.color,
        data: data,
      ),
    ];

    return Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 500.0,
        child: charts.BarChart(
          series,
          animate: true,
        ),
      ),
    );
  }
}
