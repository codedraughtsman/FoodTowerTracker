import 'dart:developer';

import 'package:foodtowertracker/FoodEntry.dart';
import 'package:foodtowertracker/PortionEntry.dart';
import 'package:intl/intl.dart';
import 'package:sqlcool/sqlcool.dart';

class DBProvider {
  static final _tableFoodData = "FoodData";
  static final tablePortionsName = "Portions";

  static var dateFormatter = new DateFormat('yyyy-MM-dd');
  static var timeFormatter = DateFormat('Hms');

  static final Db db = Db();

  static getFilteredFoodEntriesQuery(String filterString) {
    return '''select foodData.* from foodData where foodData.name like "%${filterString}%"''';
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

  static getDailyTotals() {
    var query =
        "select portions.date, sum( portions.grams * foodData.energy / foodData.measure) as totalEnergy from portions left join foodData on foodData.foodId = portions.foodId group by portions.date";

    var queryAll =
        '''select portions.date, sum( portions.grams * foodData.energy / foodData.measure) as totalEnergy,
SUM( portions.grams * "foodData.measure" / foodData.measure) as measure,
 SUM( portions.grams * foodData.water / foodData.measure) as water,
 SUM( portions.grams * foodData.energy / foodData.measure) as energy,
 SUM( portions.grams * "foodData.energy(NIP)" / foodData.measure) as "energy(NIP)",
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
from portions left join foodData on foodData.foodId = portions.foodId group by portions.date;''';

    return queryAll;
  }
}
