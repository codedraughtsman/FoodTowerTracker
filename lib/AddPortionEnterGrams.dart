import 'package:flutter/material.dart';
import 'package:foodtowertracker/FoodEntry.dart';

import 'DataBase.dart';

class AddPortionEnterGramsState extends State<AddPortionEnterGrams> {
  FoodEntry _foodEntry;
  final myController = TextEditingController();
  AddPortionEnterGramsState(this._foodEntry) {}
  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  _onSubmitted(String dummy) {
//    _onAdd();
  }

  _onAdd() {
    DBProvider.newPortion(
        foodId: _foodEntry.foodId,
        grams: int.parse(myController.text),
        time: DateTime.now());
    //todo error checking
//    var items =
//        '''measure,water,energy,energy(NIP),protein,fat,carbohydrateavailable,dietaryfibre,sugars,starch,SFA,MUFA,PUFA,Alpha-linolenicacid,Linoleicacid,Cholesterol,SodiumNa,IodineI,PotassiumK,PhosphorusP,CalciumCa,IronFe,ZincZn,SeleniumSe,VitaminA,Beta-carotene,Thiamin,Riboflavin,Niacin,VitaminB6,VitaminB12,Dietaryfolate,VitaminC,VitaminD,VitaminE'''
//            .split(",");
//    String outString = "";
//    for (final item in items) {
//      outString +=
//          ''' SUM( portions.grams * foodData.$item / foodData.measure) as $item,\n''';
//    }
//    log(outString);
//    _showToast(context);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Amount of food to add"),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "add",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _onAdd,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'enter grams eaten',
                enabled: true,
              ),
              onSubmitted: _onSubmitted,
              onEditingComplete: _onAdd,
              controller: myController,
            ),
            Text(_foodEntry.name),
          ],
        ),
      ),
    );
  }
}

class AddPortionEnterGrams extends StatefulWidget {
  FoodEntry _foodEntry;
  AddPortionEnterGrams(this._foodEntry) {}
  @override
  AddPortionEnterGramsState createState() =>
      AddPortionEnterGramsState(_foodEntry);
}
