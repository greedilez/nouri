import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/analytics_service.dart';
import 'core/app_dependencies.dart';
import 'core/notification_service.dart';
import 'data/meal_repository.dart';
import 'firebase_options.dart';
import 'presentation/app.dart';
import 'presentation/viewmodels/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await configureDependencies();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final viewModel = AppViewModel(
    dependencies<MealRepository>(),
    dependencies<AnalyticsService>(),
  );
  runApp(NouriApp(viewModel: viewModel));
  await viewModel.load();
  await dependencies<NotificationService>().initialize();
  await dependencies<AnalyticsService>().log('app_ready');
}
