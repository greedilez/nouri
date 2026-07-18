import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract class MealRepository {
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
  Future<List<PlanItem>> loadPlan();
  Future<void> savePlan(List<PlanItem> items);
  Future<List<ShoppingItem>> loadShopping();
  Future<void> saveShopping(List<ShoppingItem> items);
  Future<List<PantryItem>> loadPantry();
  Future<void> savePantry(List<PantryItem> items);
}

class LocalMealRepository implements MealRepository {
  LocalMealRepository(this.preferences);

  final SharedPreferences preferences;

  static const settingsKey = 'nouri_settings';
  static const planKey = 'nouri_plan';
  static const shoppingKey = 'nouri_shopping';
  static const pantryKey = 'nouri_pantry';

  @override
  Future<UserSettings> loadSettings() async {
    final value = preferences.getString(settingsKey);
    return value == null
        ? const UserSettings()
        : UserSettings.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSettings(UserSettings settings) =>
      preferences.setString(settingsKey, jsonEncode(settings.toJson()));

  @override
  Future<List<PlanItem>> loadPlan() async =>
      _loadList(planKey, (value) => PlanItem.fromJson(value));

  @override
  Future<void> savePlan(List<PlanItem> items) =>
      _saveList(planKey, items.map((item) => item.toJson()).toList());

  @override
  Future<List<ShoppingItem>> loadShopping() async =>
      _loadList(shoppingKey, (value) => ShoppingItem.fromJson(value));

  @override
  Future<void> saveShopping(List<ShoppingItem> items) =>
      _saveList(shoppingKey, items.map((item) => item.toJson()).toList());

  @override
  Future<List<PantryItem>> loadPantry() async =>
      _loadList(pantryKey, (value) => PantryItem.fromJson(value));

  @override
  Future<void> savePantry(List<PantryItem> items) =>
      _saveList(pantryKey, items.map((item) => item.toJson()).toList());

  List<T> _loadList<T>(String key, T Function(Map<String, dynamic>) decode) {
    final value = preferences.getString(key);
    if (value == null) return [];
    return (jsonDecode(value) as List<dynamic>)
        .map((item) => decode(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> value) =>
      preferences.setString(key, jsonEncode(value));
}
