import 'dart:developer';

import 'package:foodtowertracker/FoodEntry.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:foodtowertracker/data/JsonHolder.dart';
import 'package:intl/intl.dart';
import 'package:sqlcool/sqlcool.dart';

class DBProvider {
  static final _tableFoodData = "FoodData";
  static final tablePortionsName = "Portions";

  static var dateFormatter = new DateFormat('yyyy-MM-dd');
  static var timeFormatter = DateFormat('Hms');

  static final Db db = Db();
  static final StringEULA_Text = """Thank you for using this app.

I wrote this app for myself, so I could track, and improve, what I was eating. It has, and continues, to make a big difference in my life, and I hope it will do the same for yours.

Here I want to explain the bounds of this app's abilities. So you can understand how to effectively use it.

The app comes preloaded with food data taken from the New Zealand Food Composition Database. See: www.https://www.foodcomposition.co.nz/ for more info.

Food data from other countries will differ. 
For example, Nz soils have very low levels of Iodine, causing foods grown in Nz to be low in Iodine. 
Please update the food's data to reflect your country.

Also preloaded in this app are several recommended daily nutrient levels. These were taken from several trusted health websites. They are for an average active adult. Please review these levels and change them to reflect what your body needs. 

Now here are the basic legal disclaimers for this app.

While I have taken steps to check that the data and advice offered by this app is correct at the time of publishing, however it may be wrong, misleading, or incorrect. It can also become out of date, and thus become wrong, misleading, or incorrect.

You use this app at your own risk.
This app is not designed for medical use.
This app, and advice offered by this app, does not in any way replace, or offer, medical advice. Please check with a trained medical practitioner before altering your diet.

I am not in any way liable for anything.""";

  static final humanReadableNames = <String, String>{
//    "totalEnergy": "kj",
    "measure": "Weight of portion of food",
    "energy": "Energy",
    "protein": "Protein",
    "fat": "Fat",
    "carbohydrateavailable": "Carbohydrate",
    "grams": "Grams of food",
    "dietaryfibre": "Dietary fibre",
    "sugars": "Sugars",
    "starch": "Starch",
    "SFA": "Saturated Fatty acids (SFA)",
    "MUFA": "Monounsaturated fatty acids (MUFA)",
    "PUFA": "polyunsaturated fatty acids (PUFA)",
    "Alpha-linolenicacid": "Alpha-linolenic acid",
    "Linoleicacid": "Linoleic acid",
    "Cholesterol": "Cholesterol",
    "SodiumNa": "Sodium",
    "IodineI": "Iodine",
    "PotassiumK": "Potassium",
    "PhosphorusP": "Phosphorus",
    "CalciumCa": "Calcium",
    "IronFe": "Iron",
    "ZincZn": "Zinc",
    "SeleniumSe": "Selenium",
    "VitaminA": "Vitamin A",
    "Beta-carotene": "Beta-carotene",
    "Thiamin": "Thiamin (Vitamin B1)",
    "Riboflavin": "Riboflavin (Vitamin B2)",
    "Niacin": "Niacin (Vitamin B3)",
    "VitaminB6": "Vitamin B6",
    "VitaminB12": "Vitamin B12",
    "Dietaryfolate": "Dietary folate (Vitamin B9)",
    "VitaminC": "Vitamin C",
    "VitaminD": "Vitamin D",
    "VitaminE": "Vitamin E",
  };

  static final units = <String, String>{
//    "totalEnergy": "kj",
    "measure": "g",
    "energy": "kj",
    "protein": "g",
    "fat": "g",
    "carbohydrateavailable": "g",
    "grams": "g",
    "dietaryfibre": "g",
    "sugars": "g",
    "starch": "g",
    "SFA": "g",
    "MUFA": "g",
    "PUFA": "g",
    "Alpha-linolenicacid": "g",
    "Linoleicacid": "g",
    "Cholesterol": "mg",
    "SodiumNa": "mg",
    "IodineI": "mg",
    "PotassiumK": "mg",
    "PhosphorusP": "mg",
    "CalciumCa": "mg",
    "IronFe": "mg",
    "ZincZn": "mg",
    "SeleniumSe": "μg",
    "VitaminA": "μg",
    "Beta-carotene": "μg",
    "Thiamin": "mg",
    "Riboflavin": "mg",
    "Niacin": "mg",
    "VitaminB6": "mg",
    "VitaminB12": "μg",
    "Dietaryfolate": "μg",
    "VitaminC": "mg",
    "VitaminD": "mg",
    "VitaminE": "mg",
  };

  static getDefaultFoodMap() {
    return <String, dynamic>{
      "foodId": -1,
      "name": "",
      "measure": 100.0,
      "energy": 0.0,
      "protein": 0.0,
      "fat": 0.0,
      "carbohydrateavailable": 0.0,
      "dietaryfibre": 0.0,
      "sugars": 0.0,
      "starch": 0.0,
      "SFA": 0.0,
      "MUFA": 0.0,
      "PUFA": 0.0,
      "Alpha-linolenicacid": 0.0,
      "Linoleicacid": 0.0,
      "Cholesterol": 0.0,
      "SodiumNa": 0.0,
      "IodineI": 0.0,
      "PotassiumK": 0.0,
      "PhosphorusP": 0.0,
      "CalciumCa": 0.0,
      "IronFe": 0.0,
      "ZincZn": 0.0,
      "SeleniumSe": 0.0,
      "VitaminA": 0.0,
      "Beta-carotene": 0.0,
      "Thiamin": 0.0,
      "Riboflavin": 0.0,
      "Niacin": 0.0,
      "VitaminB6": 0.0,
      "VitaminB12": 0.0,
      "Dietaryfolate": 0.0,
      "VitaminC": 0.0,
      "VitaminD": 0.0,
      "VitaminE": 0.0,
    };
  }

  static bool getShowEULA() async {
    var result;

    try {
      result = await db.query("select EULA.* from EULA");
    } catch (error) {
      rethrow;
    }
    log("result is ${result}");
    return true;
  }

  static getFilteredFoodEntriesQuery(String filterString) {
    return '''select foodData.* from foodData where foodData.name like "%${filterString}%"''';
  }

  static String doubleToStringConverter(double value) {
    return value.toStringAsFixed(3);
  }

  static deletePortionEntry(PortionEntry portionEntry) async {
    try {
      await db.delete(
          table: tablePortionsName,
          where: "portionId = ${portionEntry.portionId}",
          verbose: true);
    } catch (e) {
      rethrow;
    }
  }

  static getUnit(String key) {
    return units[key];
  }

  static getPortionsKeys() {
    return units.keys.toList();
  }

  static saveFood(JsonHolder food) async {
    Map<String, String> data = Map<String, String>();

    for (String key in food.json.keys) {
      if (key == "foodId") {
        //don't add the the id becaues we want the db to auto create it.
        continue;
      }
      final String escapedKey = """'$key'""";
      data.putIfAbsent(escapedKey, () => food.getAsString(key));
    }
    log("data being saved is: ${data}");
    try {
      await db.insert(table: "foodData", row: data, verbose: true);
    } catch (e) {
      log("had an error saving food: ${e}");
      rethrow;
    }
  }

  static updateFood(JsonHolder food) async {
    Map<String, String> data = Map<String, String>();

    for (String key in food.json.keys) {
      final String escapedKey = """'$key'""";
      data.putIfAbsent(escapedKey, () => food.getAsString(key));
    }
    try {
      int numRowsUpdated = await db.update(
          table: "foodData",
          row: data,
          where: "foodId=${food.getAsString("foodId")}");
    } catch (e) {
      rethrow;
    }
  }

  static getPortions() async {
    var query =
        "select * from portions left join foodData on portions.foodId = foodData.foodId;";
    var rows = await db.query(query, verbose: true);
    List<PortionEntry> list = rows.isNotEmpty
        ? rows.map((c) => PortionEntry.fromMap(c)).toList()
        : [];
    return list;
  }

  static newPortion({int foodId, int grams, DateTime time}) async {
    log("adding new portin $foodId");
    var map = Map<String, String>();
    map['foodId'] = foodId.toString();
    map['grams'] = grams.toString();

    map['date'] = dateFormatter.format(time);
    map['time'] = timeFormatter.format(time);

    var res =
        await db.insert(table: tablePortionsName, row: map, verbose: true);
    log("results from newFoodEntry query are $res");
    return res;
  }

  static getFoodEntry(int findId) async {
    List<Map<String, dynamic>> rows = await db.select(
      table: _tableFoodData,
      where: "foodId = $findId",
    );
    if (rows.length != 1) {
      //error
      log("error getFoodEntry for foodId $findId returned ${rows.length}, it should be one");
    }
    return FoodEntry.fromMap(rows[0]);
  }

  static getDailyFoodSumsQuery(DateTime date) {
    var dateString = dateFormatter.format(date);
    return '''select sum(portions.grams) as grams, portions.date, foodData.* from portions left join foodData on portions.foodId = foodData.foodId where portions.date = "$dateString" group by portions.date, portions.foodId ORDER BY (grams * foodData.energy);''';
  }

  static String FilterStringToday() {
    var dateString = dateFormatter.format(DateTime.now());
    return 'portions.date == "${dateString}"';
  }

  /*
  datetime is the day of the week that you want to get data for.
   */
  static getWeeklyTotals({DateTime dateTime = null}) {
    var daysSinceMonday = 6;
    var startOfWeekDate = dateTime.subtract(Duration(days: daysSinceMonday));
    var daysInWeek = <DateTime>[
      startOfWeekDate,
      startOfWeekDate.add(Duration(days: 1)),
      startOfWeekDate.add(Duration(days: 2)),
      startOfWeekDate.add(Duration(days: 3)),
      startOfWeekDate.add(Duration(days: 4)),
      startOfWeekDate.add(Duration(days: 5)),
      startOfWeekDate.add(Duration(days: 6)),
    ];
//    JsonHolder totalResults = null;
//    for (DateTime dayDateTime in daysInWeek) {
//      var results = getDailyTotals(dateTime: dayDateTime);
//      totalResults.add(JsonHolder(results));
//    }
//    return totalResults;
    return getDailyTotals(multipleDays: daysInWeek);
  }

  static getDailyTotals(
      {DateTime dateTime = null, List<DateTime> multipleDays = null}) {
    String queryAll =
        '''select portions.date, sum( portions.grams * foodData.energy / foodData.measure) as totalEnergy,
SUM( portions.grams * "foodData.measure" / foodData.measure) as measure,
SUM( portions.grams ) as grams,
 SUM( portions.grams * foodData.water / foodData.measure) as water,
 SUM( portions.grams * foodData.energy / foodData.measure) as energy,
 SUM( portions.grams * foodData.protein / foodData.measure) as protein,
 SUM( portions.grams * foodData.fat / foodData.measure) as fat,
 SUM( portions.grams * foodData.carbohydrateavailable / foodData.measure) as carbohydrateavailable,
 SUM( portions.grams * foodData.dietaryfibre / foodData.measure) as dietaryfibre,
 SUM( portions.grams * foodData.sugars / foodData.measure) as sugars,
 SUM( portions.grams * foodData.starch / foodData.measure) as starch,
 SUM( portions.grams * foodData.SFA / foodData.measure) as SFA,
 SUM( portions.grams * foodData.MUFA / foodData.measure) as MUFA,
 SUM( portions.grams * foodData.PUFA / foodData.measure) as PUFA,
 SUM( portions.grams * "foodData.Alpha-linolenicacid" / foodData.measure) as "Alpha-linolenicacid",
 SUM( portions.grams * foodData.Linoleicacid / foodData.measure) as Linoleicacid,
 SUM( portions.grams * foodData.Cholesterol / foodData.measure) as Cholesterol,
 SUM( portions.grams * foodData.SodiumNa / foodData.measure) as SodiumNa,
 SUM( portions.grams * foodData.IodineI / foodData.measure) as IodineI,
 SUM( portions.grams * foodData.PotassiumK / foodData.measure) as PotassiumK,
 SUM( portions.grams * foodData.PhosphorusP / foodData.measure) as PhosphorusP,
 SUM( portions.grams * foodData.CalciumCa / foodData.measure) as CalciumCa,
 SUM( portions.grams * foodData.IronFe / foodData.measure) as IronFe,
 SUM( portions.grams * foodData.ZincZn / foodData.measure) as ZincZn,
 SUM( portions.grams * foodData.SeleniumSe / foodData.measure) as SeleniumSe,
 SUM( portions.grams * foodData.VitaminA / foodData.measure) as VitaminA,
 SUM( portions.grams * "foodData.Beta-carotene" / foodData.measure) as "Beta-carotene",
 SUM( portions.grams * foodData.Thiamin / foodData.measure) as Thiamin,
 SUM( portions.grams * foodData.Riboflavin / foodData.measure) as Riboflavin,
 SUM( portions.grams * foodData.Niacin / foodData.measure) as Niacin,
 SUM( portions.grams * foodData.VitaminB6 / foodData.measure) as VitaminB6,
 SUM( portions.grams * foodData.VitaminB12 / foodData.measure) as VitaminB12,
 SUM( portions.grams * foodData.Dietaryfolate / foodData.measure) as Dietaryfolate,
 SUM( portions.grams * foodData.VitaminC / foodData.measure) as VitaminC,
 SUM( portions.grams * foodData.VitaminD / foodData.measure) as VitaminD,
 SUM( portions.grams * foodData.VitaminE / foodData.measure) as VitaminE
from portions left join foodData on foodData.foodId = portions.foodId ''';
    if (multipleDays != null) {
      queryAll += ' where ';
      var counter = 0;
      for (DateTime date in multipleDays) {
        if (counter > 0) {
          queryAll += 'or ';
        }
        var dateString = dateFormatter.format(date);
        queryAll += ' portions.date = "$dateString" ';
        counter++;
      }
    } else if (dateTime != null) {
      log("adding datestring formatter");
      var dateString = dateFormatter.format(dateTime);
      queryAll += ' where portions.date = "$dateString" ';
    }
//    queryAll += ''' group by portions.date ORDER BY (portions.date) DESC;''';

    log("last n of query string ${queryAll.substring(queryAll.length - 300)}");
    return queryAll;
  }
}
