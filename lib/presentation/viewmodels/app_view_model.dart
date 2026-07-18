import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../core/analytics_service.dart';
import '../../data/meal_repository.dart';
import '../../data/recipe_catalog.dart';
import '../../domain/models.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel(this.repository, this.analytics);

  final MealRepository repository;
  final AnalyticsService analytics;
  UserSettings settings = const UserSettings();
  List<PlanItem> plan = [];
  List<ShoppingItem> shopping = [];
  List<PantryItem> pantry = [];
  bool loaded = false;

  Future<void> load() async {
    settings = await repository.loadSettings();
    plan = await repository.loadPlan();
    shopping = await repository.loadShopping();
    pantry = await repository.loadPantry();
    loaded = true;
    notifyListeners();
  }

  Recipe recipe(String id) => recipeCatalog.firstWhere((item) => item.id == id);

  List<PlanItem> planFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final result = plan.where((item) => item.date == key).toList();
    result.sort((a, b) => a.slot.index.compareTo(b.slot.index));
    return result;
  }

  int caloriesFor(DateTime date) => planFor(
    date,
  ).fold(0, (total, item) => total + recipe(item.recipeId).calories);

  int proteinFor(DateTime date) => planFor(
    date,
  ).fold(0, (total, item) => total + recipe(item.recipeId).protein);

  int get completedMeals => plan.where((item) => item.completed).length;

  Future<void> setTheme(AppThemeChoice theme) async {
    settings = settings.copyWith(theme: theme);
    notifyListeners();
    await repository.saveSettings(settings);
    await analytics.log('theme_changed', {'theme': theme.name});
    await analytics.setUserProfile(diet: settings.diet, theme: theme.name);
  }

  Future<void> finishOnboarding({
    required String name,
    required String diet,
    required int calories,
  }) async {
    settings = settings.copyWith(
      name: name.trim(),
      diet: diet,
      dailyCalories: calories,
      onboardingComplete: true,
    );
    notifyListeners();
    await repository.saveSettings(settings);
    await analytics.log('onboarding_completed', {
      'diet': diet,
      'daily_calories': calories,
    });
    await analytics.setUserProfile(diet: diet, theme: settings.theme.name);
  }

  Future<void> finishTutorial() async {
    settings = settings.copyWith(tutorialComplete: true);
    notifyListeners();
    await repository.saveSettings(settings);
    await analytics.log('tutorial_completed');
  }

  Future<void> resetTutorial() async {
    settings = settings.copyWith(tutorialComplete: false);
    notifyListeners();
    await repository.saveSettings(settings);
  }

  Future<void> updateProfile({
    required String name,
    required String diet,
    required int calories,
  }) async {
    settings = settings.copyWith(
      name: name.trim(),
      diet: diet,
      dailyCalories: calories,
    );
    notifyListeners();
    await repository.saveSettings(settings);
  }

  Future<void> addMeal({
    required DateTime date,
    required MealSlot slot,
    required Recipe selectedRecipe,
    required int servings,
  }) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    plan.removeWhere((item) => item.date == dateKey && item.slot == slot);
    plan.add(
      PlanItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: dateKey,
        slot: slot,
        recipeId: selectedRecipe.id,
        servings: servings,
      ),
    );
    notifyListeners();
    await repository.savePlan(plan);
    await analytics.log('meal_added', {
      'slot': slot.name,
      'recipe_id': selectedRecipe.id,
      'servings': servings,
    });
  }

  Future<void> removeMeal(String id) async {
    plan.removeWhere((item) => item.id == id);
    notifyListeners();
    await repository.savePlan(plan);
  }

  Future<void> toggleMeal(String id) async {
    plan = plan
        .map(
          (item) =>
              item.id == id ? item.copyWith(completed: !item.completed) : item,
        )
        .toList();
    notifyListeners();
    await repository.savePlan(plan);
  }

  Future<void> buildShoppingFromPlan() async {
    final existing = shopping.map((item) => item.name.toLowerCase()).toSet();
    final upcoming = plan.where((item) {
      final date = DateTime.tryParse(item.date);
      if (date == null) return false;
      return date.difference(DateTime.now()).inDays >= -1 &&
          date.difference(DateTime.now()).inDays <= 7;
    });
    for (final item in upcoming) {
      for (final ingredient in recipe(item.recipeId).ingredients) {
        if (existing.add(ingredient.toLowerCase())) {
          shopping.add(
            ShoppingItem(
              id:
                  DateTime.now().microsecondsSinceEpoch.toString() +
                  shopping.length.toString(),
              name: ingredient,
              category: ingredientCategory(ingredient),
              quantity: '${item.servings} serving',
            ),
          );
        }
      }
    }
    notifyListeners();
    await repository.saveShopping(shopping);
    await analytics.log('shopping_list_generated', {
      'item_count': shopping.length,
    });
  }

  Future<void> addShopping({
    required String name,
    required String quantity,
    required String category,
  }) async {
    shopping.add(
      ShoppingItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category,
        quantity: quantity.trim(),
      ),
    );
    notifyListeners();
    await repository.saveShopping(shopping);
  }

  Future<void> toggleShopping(String id) async {
    shopping = shopping
        .map(
          (item) =>
              item.id == id ? item.copyWith(checked: !item.checked) : item,
        )
        .toList();
    notifyListeners();
    await repository.saveShopping(shopping);
  }

  Future<void> clearCheckedShopping() async {
    shopping.removeWhere((item) => item.checked);
    notifyListeners();
    await repository.saveShopping(shopping);
  }

  Future<void> addPantry({
    required String name,
    required String quantity,
    required String category,
    required DateTime expiry,
  }) async {
    pantry.add(
      PantryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category,
        quantity: quantity.trim(),
        expiry: DateFormat('yyyy-MM-dd').format(expiry),
      ),
    );
    notifyListeners();
    await repository.savePantry(pantry);
    await analytics.log('pantry_item_added', {'category': category});
  }

  Future<void> removePantry(String id) async {
    pantry.removeWhere((item) => item.id == id);
    notifyListeners();
    await repository.savePantry(pantry);
  }

  Future<void> eraseUserData() async {
    plan.clear();
    shopping.clear();
    pantry.clear();
    settings = UserSettings(
      theme: settings.theme,
      onboardingComplete: true,
      tutorialComplete: true,
    );
    notifyListeners();
    await repository.savePlan(plan);
    await repository.saveShopping(shopping);
    await repository.savePantry(pantry);
    await repository.saveSettings(settings);
  }

  String ingredientCategory(String ingredient) {
    final value = ingredient.toLowerCase();
    if (value.contains('salmon') || value.contains('chicken')) return 'Protein';
    if (value.contains('yogurt') ||
        value.contains('milk') ||
        value.contains('parmesan')) {
      return 'Dairy';
    }
    if (value.contains('oats') ||
        value.contains('quinoa') ||
        value.contains('spaghetti')) {
      return 'Grains';
    }
    return 'Produce';
  }
}
