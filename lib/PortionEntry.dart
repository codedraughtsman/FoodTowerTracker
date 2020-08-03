import 'package:foodtowertracker/FoodEntry.dart';

class PortionEntry extends FoodEntry {
  int grams;
  int portionId;
  int id;
  double totalEnergy;
  String date, time;
  Map<String, dynamic> json;

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
    portionId = json["portionId"];
    if (json.containsKey("portionId")) {
      id = json["portionId"];
    } else {
      id = -1;
    }
    _updateCalculatedValues();
    this.json = json;
  }

  //todo call this whenever these values change
  _updateCalculatedValues() {
    if (grams != null && energy != null) {
      totalEnergy = grams * energy / measure;
    }
  }

  double getTotalValueInMeasure(String valueId) {
    if (valueId == "totalEnergy") {
      return totalEnergy.toDouble();
    }
    double grams = getMappedValue("grams");
    double measure = getMappedValue("measure");
    double value = getMappedValue(valueId);
    return grams * value / measure;
  }

  double getMappedValue(String valueId) {
    if (valueId == "totalEnergy") {
      return totalEnergy.toDouble();
    }
    if (json[valueId] == null) {
      return 0.0;
    }
    double parsedValue = double.tryParse(json[valueId].toString());
    if (parsedValue == null) {
      return 0.0;
    }

    return parsedValue;
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
