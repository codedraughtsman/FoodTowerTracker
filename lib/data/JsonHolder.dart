import 'dart:developer';

import 'package:foodtowertracker/DataBase.dart';

class JsonHolder {
  Map<String, dynamic> json;
  JsonHolder(this.json);

  factory JsonHolder.fromMap(Map<String, dynamic> fromJson) {
    var portion = JsonHolder(fromJson);
    return portion;
  }
  factory JsonHolder.makePortion() {
    return JsonHolder(DBProvider.getDefaultFoodMap());
  }
  String getAsString(String key) {
    return json[key].toString();
  }

  String toString() {
    return super.toString() + " $json";
  }

  add(JsonHolder holder) {
    for (String key in holder.json.keys) {
      //just add it if it does not exist.
      if (!json.containsKey(key)) {
        json[key] = holder.json[key];
        continue;
      }

      String valueStr1 = getAsString(key);
      String valueStr2 = holder.getAsString(key);

      double value1 = double.tryParse(valueStr1);
      double value2 = double.tryParse(valueStr2);

      if (value1 != null && value2 != null) {
        //combine the values
        json[key] = value1 + value2;
      } else {
        //ignore this value;
        log("could not combine $key, arg 1: $valueStr1, arg 2: $valueStr2");
      }
    }
  }
}
