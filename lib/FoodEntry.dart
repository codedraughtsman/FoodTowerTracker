import 'dart:convert';

import 'FoodNutrition.dart';

FoodEntry clientFromJson(String str) {
  final jsonData = json.decode(str);
  return FoodEntry.fromMap(jsonData);
}

String clientToJson(FoodEntry data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class FoodEntry extends FoodNutrition {
  String name;
  int energy;
  int foodId;

  FoodEntry({this.name = "", this.energy = 0, this.foodId = -1}) : super() {}

  factory FoodEntry.fromMap(Map<String, dynamic> json) {
    var food = new FoodEntry();
    food.setValuesFromMap(json);
    return food;
  }

  setValuesFromMap(Map<String, dynamic> json) {
    name = json["name"];
    foodId = json["foodId"];
    super.setValuesFromMap(json);
  }

  Map<String, String> toMap() {
    Map<String, String> data = {
      "foodId": foodId.toString(),
      "name": name,
    };
    data.addAll(super.toMap());
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString() + "foodId $foodId, name $name";
  }
}
