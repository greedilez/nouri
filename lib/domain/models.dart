enum AppThemeChoice { light, dark }

enum MealSlot { breakfast, lunch, dinner, snack }

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.minutes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.steps,
    required this.imageAlignment,
    required this.tags,
  });

  final String id;
  final String name;
  final String subtitle;
  final int minutes;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final List<String> steps;
  final double imageAlignment;
  final List<String> tags;
}

class PlanItem {
  const PlanItem({
    required this.id,
    required this.date,
    required this.slot,
    required this.recipeId,
    required this.servings,
    this.completed = false,
  });

  final String id;
  final String date;
  final MealSlot slot;
  final String recipeId;
  final int servings;
  final bool completed;

  PlanItem copyWith({bool? completed}) => PlanItem(
    id: id,
    date: date,
    slot: slot,
    recipeId: recipeId,
    servings: servings,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'slot': slot.name,
    'recipeId': recipeId,
    'servings': servings,
    'completed': completed,
  };

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
    id: json['id'] as String,
    date: json['date'] as String,
    slot: MealSlot.values.byName(json['slot'] as String),
    recipeId: json['recipeId'] as String,
    servings: json['servings'] as int,
    completed: json['completed'] as bool? ?? false,
  );
}

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.checked = false,
  });

  final String id;
  final String name;
  final String category;
  final String quantity;
  final bool checked;

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
    id: id,
    name: name,
    category: category,
    quantity: quantity,
    checked: checked ?? this.checked,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'checked': checked,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    quantity: json['quantity'] as String,
    checked: json['checked'] as bool? ?? false,
  );
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.expiry,
  });

  final String id;
  final String name;
  final String category;
  final String quantity;
  final String expiry;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'expiry': expiry,
  };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    quantity: json['quantity'] as String,
    expiry: json['expiry'] as String,
  );
}

class UserSettings {
  const UserSettings({
    this.name = '',
    this.theme = AppThemeChoice.light,
    this.onboardingComplete = false,
    this.tutorialComplete = false,
    this.dailyCalories = 2000,
    this.diet = 'Balanced',
  });

  final String name;
  final AppThemeChoice theme;
  final bool onboardingComplete;
  final bool tutorialComplete;
  final int dailyCalories;
  final String diet;

  UserSettings copyWith({
    String? name,
    AppThemeChoice? theme,
    bool? onboardingComplete,
    bool? tutorialComplete,
    int? dailyCalories,
    String? diet,
  }) => UserSettings(
    name: name ?? this.name,
    theme: theme ?? this.theme,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    tutorialComplete: tutorialComplete ?? this.tutorialComplete,
    dailyCalories: dailyCalories ?? this.dailyCalories,
    diet: diet ?? this.diet,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'theme': theme.name,
    'onboardingComplete': onboardingComplete,
    'tutorialComplete': tutorialComplete,
    'dailyCalories': dailyCalories,
    'diet': diet,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    name: json['name'] as String? ?? '',
    theme: AppThemeChoice.values.byName(json['theme'] as String? ?? 'light'),
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    tutorialComplete: json['tutorialComplete'] as bool? ?? false,
    dailyCalories: json['dailyCalories'] as int? ?? 2000,
    diet: json['diet'] as String? ?? 'Balanced',
  );
}
