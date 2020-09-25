import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:foodtowertracker/FoodEntry.dart';
import 'package:foodtowertracker/HelpButton.dart';

import 'DataBase.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class AddPortionEnterGramsState extends State<AddPortionEnterGrams> {
  FoodEntry _foodEntry;
  DateTime _dateTime;
  final myController = TextEditingController();

  AddPortionEnterGramsState(this._foodEntry) {
    _dateTime = DateTime.now();
  }
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
        time: _dateTime);
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

  String dateToText(DateTime date) {
    Duration diff = DateTime.now().difference(_dateTime);
    var diffDays = diff.inDays;

    String output = 'Date:' +
        "${_dateTime.year.toString()}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}";

    log("DateTime.now(), ${DateTime.now().toString()}, _date ${_dateTime.toString()}, diff ${diff} ");
    if (diffDays == 0) {
      output += " Today";
    } else if (diffDays == 1) {
      output += " -Yesterday";
    } else {
      output += "  ${diffDays} days ago";
    }

    return output;
  }

  void updateDate(DateTime date) {
    setState(() {
      _dateTime = date;
    });
    log('change $date');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Quantity"),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              "add",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _onAdd,
          ),
          HelpButton("Help - Enter quantity",
              """Here you can enter the quantity of the food you are adding.

You can also set the date on which you ate it."""),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2018, 3, 5),
                      maxTime: DateTime.now(), onChanged: (date) {
                    updateDate(date);
                  }, onConfirm: (date) {
                    _dateTime = date;
                    log("dateTimes set to ${date.toString()}");
                  }, currentTime: _dateTime, locale: LocaleType.en);
                },
                child: Text(
                  dateToText(_dateTime),
                  style: TextStyle(color: Colors.blue),
                )),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter grams eaten',
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
