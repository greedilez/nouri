import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/meal_repository.dart';
import 'analytics_service.dart';
import 'notification_service.dart';

final dependencies = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  dependencies.registerSingleton<SharedPreferences>(preferences);
  dependencies.registerSingleton<MealRepository>(
    LocalMealRepository(preferences),
  );
  dependencies.registerSingleton<AnalyticsService>(
    AnalyticsService(FirebaseAnalytics.instance),
  );
  dependencies.registerSingleton<NotificationService>(
    NotificationService(FirebaseMessaging.instance, FirebaseAnalytics.instance),
  );
}
