import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sqlcool/sqlcool.dart';

import 'DataBase.dart';
import 'HelpButton.dart';

class SetNutrentLevels extends StatefulWidget {
  @override
  _SetNutrentLevelsState createState() => _SetNutrentLevelsState();
}

class _SetNutrentLevelsState extends State<SetNutrentLevels> {
  var data = <String, dynamic>{
    "energy": <String, dynamic>{
      "longName": "Energy",
      "showNutrent": true,
      "showDailyLimit": true,
      "showRDI": true,
      "rangeMin": 7000,
      "rangeMax": 8000,
      "upperLimit": 10000,
    },
    "protein": <String, dynamic>{
      "longName": "Protein",
      "showNutrent": true,
      "showDailyLimit": true,
      "showRDI": true,
      "rangeMin": 100,
      "rangeMax": 140,
      "upperLimit": -1,
    },
  };

  SelectBloc bloc;

  @override
  void initState() {
    this.bloc = SelectBloc(
      table: "nutrientSettings",
      columns: "*",
      verbose: true,
      database: DBProvider.db,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var keys = data.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrients'),
        actions: <Widget>[
          HelpButton("Help - Nutrients",
              """Here is where you can see the nutritional composition of what you have eaten today.

Tap on a nutrient to open a tower view of the foods that you have eaten with that nutrient.

Units:
    g - Grams
    mg - Milligram. 1000 mg = 1g
    μg - Microgram. Also abbreviated to mcg. 
           1000 μg = 1 mg"""),
        ],
      ),
      body: StreamBuilder<List<Map>>(
        stream: bloc.items,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return FittedBox(
              fit: BoxFit.contain,
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            child: ListView.separated(
                padding: EdgeInsets.only(top: 16.0),
                itemCount: snapshot.data.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
//                  var key = keys[index];
//                  var rowData = data[key];
                  return _buildRow(snapshot.data[index]);
                }),
          );
        },
      ),
    );
  }

  Widget _buildEntry(data, key, title) {
    return TextField(
      controller: TextEditingController(text: data[key].toString()),
      decoration: new InputDecoration(labelText: title),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
//              FilteringTextInputFormatter.digitsOnly
        WhitelistingTextInputFormatter.digitsOnly
      ],
    );
  }

  Widget _buildSwitch(data, key, title) {
    return Row(
      children: <Widget>[
        Text(title),
        Switch(
          value: data[key] == 1,
          onChanged: (value) {
            setState(
              () {
                data[key] = value;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRow(data) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                data["longName"],
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          _buildSwitch(data, "showNutrent", "Show nutrient"),
          _buildSwitch(data, "showRDI", "Show RDI"),
          _buildEntry(data, "RDI_Min", "Enter Minimum RDI"),
          _buildEntry(data, "RDI_Max", "Enter Maximum RDI"),
          _buildSwitch(data, "showLimit", "Show daily maximum limit"),
          _buildEntry(data, "maxLimit", "Enter Maximum daily limit"),
        ],
      ),
    );
  }
}
