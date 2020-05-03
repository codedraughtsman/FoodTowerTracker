import 'package:foodtowertracker/FoodNutrition.dart';

class AggregatedData extends FoodNutrition {
  String date, time;

  AggregatedData() {}
  factory AggregatedData.fromMap(Map<String, dynamic> json) {
    var food = new AggregatedData();
    food.setValuesFromMap(json);
    return food;
  }

  setValuesFromMap(Map<String, dynamic> json) {
    date = json["date"];
    time = json["time"];

    super.setValuesFromMap(json);
  }

  Map<String, String> toMap() {
    Map<String, String> data = {
      "date": date,
      "time": time,
    };
    data.addAll(super.toMap());
  }

  @override
  String toString() {
    return super.toString() + "date $date, time $time";
  }
}
