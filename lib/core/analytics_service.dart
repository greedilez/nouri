import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this.analytics);

  final FirebaseAnalytics analytics;

  Future<void> log(String name, [Map<String, Object>? parameters]) =>
      analytics.logEvent(name: name, parameters: parameters);

  Future<void> setUserProfile({
    required String diet,
    required String theme,
  }) async {
    await analytics.setUserProperty(name: 'diet_style', value: diet);
    await analytics.setUserProperty(name: 'app_theme', value: theme);
  }
}
