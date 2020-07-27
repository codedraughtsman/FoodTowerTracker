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
}
