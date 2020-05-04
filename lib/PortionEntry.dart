import 'package:foodtowertracker/FoodEntry.dart';

class PortionEntry extends FoodEntry {
  int grams;
  int portionId;
  int id;
  double totalEnergy;
  String date, time;

  PortionEntry({this.grams, this.id = -1, foodId, name, energy})
      : super(name: name, energy: energy, foodId: foodId) {
    _updateCalculatedValues();
  }

  factory PortionEntry.fromMap(Map<String, dynamic> json) {
    var portion = PortionEntry();
    portion.setValuesFromMap(json);
    return portion;
  }
  setValuesFromMap(Map<String, dynamic> json) {
    super.setValuesFromMap(json);
    grams = json["grams"];
    date = json["date"];
    time = json["time"];
    if (json.containsKey("portionId")) {
      id = json["portionId"];
    } else {
      id = -1;
    }
    _updateCalculatedValues();
  }

  //todo call this whenever these values change
  _updateCalculatedValues() {
    if (grams != null && energy != null) {
      totalEnergy = grams * energy / measure;
    }
  }

  Map<String, String> toMap() => {
        "portionId": portionId.toString(),
        "name": name,
        "energy": energy.toString(),
        "date": date,
        "time": time,
      };
  @override
  String toString() {
    return super.toString() + " id $id, grams: $grams";
  }
}
