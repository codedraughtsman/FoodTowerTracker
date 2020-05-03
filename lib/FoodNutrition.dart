class FoodNutrition {
  int energy;

  FoodNutrition() {}

  factory FoodNutrition.fromMap(Map<String, dynamic> json) {
    var food = new FoodNutrition();
    food.setValuesFromMap(json);
    return food;
  }

  setValuesFromMap(Map<String, dynamic> json) {
    energy = json["energy"];
  }

  Map<String, String> toMap() => {
        "energy": energy.toString(),
      };
  @override
  String toString() {
    // TODO: implement toString
    return super.toString() + " energy $energy";
  }
}
