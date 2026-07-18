import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_dependencies.dart';
import '../core/notification_service.dart';
import '../data/recipe_catalog.dart';
import '../domain/models.dart';
import 'viewmodels/app_view_model.dart';

const mint = Color(0xFF53D7A0);
const coral = Color(0xFFFF6D66);
const teal = Color(0xFF06343A);
const cream = Color(0xFFF7F6F0);
const gold = Color(0xFFF2C66D);

class NouriApp extends StatelessWidget {
  const NouriApp({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final dark = viewModel.settings.theme == AppThemeChoice.dark;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nouri',
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(false),
          darkTheme: _theme(true),
          home: !viewModel.loaded
              ? const SplashScreen()
              : !viewModel.settings.onboardingComplete
              ? OnboardingScreen(viewModel: viewModel)
              : !viewModel.settings.tutorialComplete
              ? TutorialScreen(viewModel: viewModel)
              : AppShell(viewModel: viewModel),
        );
      },
    );
  }

  ThemeData _theme(bool dark) {
    final base = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mint,
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: mint,
        secondary: coral,
        surface: dark ? const Color(0xFF092A2E) : const Color(0xFFF5F7F3),
      ),
      scaffoldBackgroundColor: dark
          ? const Color(0xFF031E22)
          : const Color(0xFFF3F5F1),
      fontFamily: 'sans-serif',
      useMaterial3: true,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: dark ? cream : const Color(0xFF102D30),
        displayColor: dark ? cream : const Color(0xFF102D30),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark
            ? Colors.white.withValues(alpha: .06)
            : Colors.white.withValues(alpha: .75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: mint.withValues(alpha: .2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: mint.withValues(alpha: .2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: mint, width: 1.5),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: teal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/meal_prep_background.png',
            fit: BoxFit.cover,
          ),
          const ColoredBox(color: Color(0x88031E22)),
          Center(
            child: FadeTransition(
              opacity: Tween(begin: .7, end: 1.0).animate(controller),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 96,
                      height: 96,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NOURI',
                    style: TextStyle(
                      color: cream,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Plan well. Eat with ease.',
                    style: TextStyle(color: Color(0xFFC5DCD5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  final nameController = TextEditingController();
  int page = 0;
  String diet = 'Balanced';
  double calories = 2000;

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/meal_prep_background.png',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? [const Color(0x55031E22), const Color(0xEE031E22)]
                    : [
                        Colors.white.withValues(alpha: .18),
                        const Color(0xF5F4F6F1),
                      ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 42,
                          height: 42,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Text(
                        'NOURI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${page + 1} / 3',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) => setState(() => page = value),
                    children: [
                      _WelcomePage(dark: dark),
                      _ThemePage(viewModel: widget.viewModel),
                      _ProfileSetupPage(
                        nameController: nameController,
                        diet: diet,
                        calories: calories,
                        onDiet: (value) => setState(() => diet = value),
                        onCalories: (value) => setState(() => calories = value),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                  child: Row(
                    children: [
                      if (page > 0)
                        IconButton.filledTonal(
                          onPressed: () => pageController.previousPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      if (page > 0) const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: const Key('onboarding-next'),
                          onPressed: () async {
                            if (page < 2) {
                              await pageController.nextPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              await widget.viewModel.finishOnboarding(
                                name: nameController.text,
                                diet: diet,
                                calories: calories.round(),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: coral,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            page == 2 ? 'Create my space' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Your week,\nbeautifully fed.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.03,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plan real meals, turn them into one shopping list, and keep what you already have in view.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: dark ? const Color(0xFFC5DCD5) : const Color(0xFF385A5D),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              OnboardingChip(Icons.calendar_month_rounded, 'Weekly plan'),
              OnboardingChip(Icons.shopping_bag_outlined, 'Smart list'),
              OnboardingChip(Icons.kitchen_outlined, 'Pantry'),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingChip extends StatelessWidget {
  const OnboardingChip(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      radius: 15,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: mint, size: 18),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ThemePage extends StatelessWidget {
  const _ThemePage({required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final current = viewModel.settings.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 38, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make it feel\nlike yours.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.03,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Choose your theme now. You can change it anytime.'),
          const SizedBox(height: 30),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ThemeCard(
                    title: 'Light',
                    subtitle: 'Fresh morning',
                    selected: current == AppThemeChoice.light,
                    darkPreview: false,
                    onTap: () => viewModel.setTheme(AppThemeChoice.light),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThemeCard(
                    title: 'Dark',
                    subtitle: 'Evening calm',
                    selected: current == AppThemeChoice.dark,
                    darkPreview: true,
                    onTap: () => viewModel.setTheme(AppThemeChoice.dark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.darkPreview,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool darkPreview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: darkPreview
              ? const Color(0xFF092E33)
              : const Color(0xFFF8F8F3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? coral : Colors.white.withValues(alpha: .25),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(color: coral.withValues(alpha: .2), blurRadius: 24),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? coral : const Color(0xFF789395),
              ),
            ),
            const Spacer(),
            Container(
              height: 128,
              decoration: BoxDecoration(
                color: darkPreview
                    ? Colors.white.withValues(alpha: .06)
                    : const Color(0xFFE8EEE8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [mint, coral]),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                color: darkPreview ? cream : teal,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: darkPreview
                    ? const Color(0xFF9DB5B3)
                    : const Color(0xFF567275),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSetupPage extends StatelessWidget {
  const _ProfileSetupPage({
    required this.nameController,
    required this.diet,
    required this.calories,
    required this.onDiet,
    required this.onCalories,
  });

  final TextEditingController nameController;
  final String diet;
  final double calories;
  final ValueChanged<String> onDiet;
  final ValueChanged<double> onCalories;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 36, 22, 10),
      children: [
        Text(
          'Set your\nstarting point.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.03,
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          key: const Key('onboarding-name'),
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Your name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Eating style',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ['Balanced', 'Vegetarian', 'High protein'])
              ChoiceChip(
                label: Text(option),
                selected: diet == option,
                onSelected: (_) => onDiet(option),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daily energy target',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${calories.round()} kcal',
              style: const TextStyle(color: coral, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: calories,
          min: 1200,
          max: 3200,
          divisions: 20,
          activeColor: coral,
          onChanged: onCalories,
        ),
      ],
    );
  }
}

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int step = 0;

  static const data = [
    (
      Icons.add_circle_outline_rounded,
      'Build your week',
      'Choose a day and meal slot, then add any recipe with the servings you need.',
    ),
    (
      Icons.playlist_add_check_circle_outlined,
      'One smart list',
      'Ingredients from your upcoming plan become a real checklist you can edit and tick off.',
    ),
    (
      Icons.kitchen_outlined,
      'Waste less',
      'Keep pantry quantities and expiry dates visible before you shop or plan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = data[step];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/meal_prep_background.png',
            fit: BoxFit.cover,
          ),
          ColoredBox(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xCC031E22)
                : Colors.white.withValues(alpha: .82),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'QUICK TOUR',
                        style: TextStyle(
                          color: coral,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: widget.viewModel.finishTutorial,
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween(begin: .9, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: GlassPanel(
                      key: ValueKey(step),
                      radius: 30,
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: step == 1
                                    ? [coral, gold]
                                    : [mint, const Color(0xFF2F9FA8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: mint.withValues(alpha: .25),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Icon(
                              current.$1,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            current.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            current.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              height: 1.5,
                              color: Color(0xFF89A4A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < data.length; index++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: index == step ? 28 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == step
                                ? coral
                                : mint.withValues(alpha: .3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (step == data.length - 1) {
                          widget.viewModel.finishTutorial();
                        } else {
                          setState(() => step++);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(
                        step == data.length - 1 ? 'Start planning' : 'Next tip',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AppPage { home, planner, recipes, shopping, insights }

extension AppPageData on AppPage {
  String get label => switch (this) {
    AppPage.home => 'Today',
    AppPage.planner => 'Plan',
    AppPage.recipes => 'Recipes',
    AppPage.shopping => 'List',
    AppPage.insights => 'Insights',
  };

  IconData get icon => switch (this) {
    AppPage.home => Icons.home_rounded,
    AppPage.planner => Icons.calendar_month_rounded,
    AppPage.recipes => Icons.restaurant_menu_rounded,
    AppPage.shopping => Icons.shopping_bag_outlined,
    AppPage.insights => Icons.donut_large_rounded,
  };
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.viewModel});

  final AppViewModel viewModel;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage page = AppPage.home;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final content = switch (page) {
      AppPage.home => HomeScreen(
        viewModel: widget.viewModel,
        date: selectedDate,
        onDate: (value) => setState(() => selectedDate = value),
        onPlan: () => setState(() => page = AppPage.planner),
        onProfile: () => showProfileScreen(context, widget.viewModel),
      ),
      AppPage.planner => PlannerScreen(
        viewModel: widget.viewModel,
        date: selectedDate,
        onDate: (value) => setState(() => selectedDate = value),
      ),
      AppPage.recipes => RecipesScreen(viewModel: widget.viewModel),
      AppPage.shopping => ShoppingScreen(viewModel: widget.viewModel),
      AppPage.insights => InsightsScreen(viewModel: widget.viewModel),
    };
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF031E22), const Color(0xFF092F32)]
                      : [const Color(0xFFF7F8F3), const Color(0xFFE7F2ED)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: KeyedSubtree(key: ValueKey(page), child: content),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: NavigationDock(
                selected: page,
                onSelected: (value) => setState(() => page = value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationDock extends StatelessWidget {
  const NavigationDock({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppPage selected;
  final ValueChanged<AppPage> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          for (final item in AppPage.values)
            Expanded(
              child: Tooltip(
                message: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 54,
                    decoration: BoxDecoration(
                      color: selected == item
                          ? coral.withValues(alpha: .16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected == item
                            ? coral.withValues(alpha: .35)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          color: selected == item
                              ? coral
                              : const Color(0xFF7A9896),
                          size: 21,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected == item
                                ? coral
                                : const Color(0xFF7A9896),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.date,
    required this.onDate,
    required this.onPlan,
    required this.onProfile,
  });

  final AppViewModel viewModel;
  final DateTime date;
  final ValueChanged<DateTime> onDate;
  final VoidCallback onPlan;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final meals = viewModel.planFor(date);
    final calories = viewModel.caloriesFor(date);
    final target = viewModel.settings.dailyCalories;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GOOD ${DateTime.now().hour < 12 ? 'MORNING' : 'EVENING'}',
                    style: const TextStyle(
                      color: mint,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.settings.name.isEmpty
                        ? 'Your table is ready'
                        : 'Hello, ${viewModel.settings.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Profile and settings',
              onPressed: onProfile,
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        WeekRibbon(selected: date, onSelected: onDate),
        const SizedBox(height: 16),
        GlassPanel(
          radius: 24,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (calories / target).clamp(0, 1),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: coral,
                      backgroundColor: mint.withValues(alpha: .15),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$calories',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text('kcal', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY BALANCE',
                      style: TextStyle(
                        color: coral,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meals.isEmpty
                          ? 'Nothing planned yet'
                          : '${meals.length} meals on your day',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${(target - calories).clamp(0, target)} kcal remaining · ${viewModel.proteinFor(date)}g protein',
                      style: const TextStyle(
                        color: Color(0xFF7C9997),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Today’s meals',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onPlan,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Plan'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (meals.isEmpty)
          EmptyAction(
            icon: Icons.restaurant_rounded,
            title: 'Start with one meal',
            body: 'Pick a recipe and give it a place in your day.',
            action: 'Open planner',
            onPressed: onPlan,
          )
        else
          for (final item in meals)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlannedMealCard(
                item: item,
                recipe: viewModel.recipe(item.recipeId),
                onToggle: () => viewModel.toggleMeal(item.id),
                onRemove: () => viewModel.removeMeal(item.id),
              ),
            ),
      ],
    );
  }
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({
    super.key,
    required this.viewModel,
    required this.date,
    required this.onDate,
  });

  final AppViewModel viewModel;
  final DateTime date;
  final ValueChanged<DateTime> onDate;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.planFor(date);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
      children: [
        const ScreenHeading(
          eyebrow: 'WEEKLY RHYTHM',
          title: 'Shape your plate',
          icon: Icons.calendar_month_rounded,
        ),
        const SizedBox(height: 16),
        WeekRibbon(selected: date, onSelected: onDate),
        const SizedBox(height: 20),
        for (final slot in MealSlot.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Builder(
              builder: (context) {
                final match = items.cast<PlanItem?>().firstWhere(
                  (item) => item?.slot == slot,
                  orElse: () => null,
                );
                return MealSlotTile(
                  slot: slot,
                  item: match,
                  recipe: match == null
                      ? null
                      : viewModel.recipe(match.recipeId),
                  onTap: () => showAddMeal(context, viewModel, date, slot),
                  onRemove: match == null
                      ? null
                      : () => viewModel.removeMeal(match.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key, required this.viewModel});
  final AppViewModel viewModel;

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String query = '';
  int visible = 4;

  @override
  Widget build(BuildContext context) {
    final filtered = recipeCatalog
        .where(
          (recipe) =>
              recipe.name.toLowerCase().contains(query.toLowerCase()) ||
              recipe.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
      children: [
        const ScreenHeading(
          eyebrow: 'COOK WITH INTENT',
          title: 'Recipe library',
          icon: Icons.restaurant_menu_rounded,
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() {
            query = value;
            visible = 4;
          }),
          decoration: const InputDecoration(
            hintText: 'Search recipes or tags',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 700 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.take(visible).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.5 : 1.15,
              ),
              itemBuilder: (context, index) {
                final recipe = filtered[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => showRecipeDetails(context, recipe),
                );
              },
            );
          },
        ),
        if (visible < filtered.length) ...[
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => setState(() => visible += 4),
            child: const Text('Load more recipes'),
          ),
        ],
      ],
    );
  }
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key, required this.viewModel});
  final AppViewModel viewModel;

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  bool pantryMode = false;

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
      children: [
        ScreenHeading(
          eyebrow: pantryMode ? 'WHAT YOU HAVE' : 'READY FOR THE STORE',
          title: pantryMode ? 'Your pantry' : 'Shopping list',
          icon: pantryMode
              ? Icons.kitchen_outlined
              : Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 14),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Shopping'),
              icon: Icon(Icons.checklist_rounded),
            ),
            ButtonSegment(
              value: true,
              label: Text('Pantry'),
              icon: Icon(Icons.kitchen_outlined),
            ),
          ],
          selected: {pantryMode},
          onSelectionChanged: (value) =>
              setState(() => pantryMode = value.first),
        ),
        const SizedBox(height: 16),
        if (!pantryMode) ...[
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: vm.buildShoppingFromPlan,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Build from plan'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Add item',
                onPressed: () => showShoppingEditor(context, vm),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (vm.shopping.isEmpty)
            EmptyAction(
              icon: Icons.shopping_cart_outlined,
              title: 'Your list is clear',
              body: 'Generate ingredients from planned meals or add an item.',
              action: 'Add item',
              onPressed: () => showShoppingEditor(context, vm),
            )
          else ...[
            for (final item in vm.shopping)
              CheckboxListTile(
                value: item.checked,
                onChanged: (_) => vm.toggleShopping(item.id),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.checked
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text('${item.quantity} · ${item.category}'),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: vm.clearCheckedShopping,
                child: const Text('Clear checked'),
              ),
            ),
          ],
        ] else ...[
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showPantryEditor(context, vm),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add pantry item'),
            ),
          ),
          const SizedBox(height: 14),
          if (vm.pantry.isEmpty)
            EmptyAction(
              icon: Icons.kitchen_outlined,
              title: 'Pantry starts empty',
              body: 'Add what you own, including quantity and expiry.',
              action: 'Add first item',
              onPressed: () => showPantryEditor(context, vm),
            )
          else
            for (final item in vm.pantry)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: mint,
                  child: Icon(Icons.inventory_2_outlined, color: teal),
                ),
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity} · expires ${DateFormat('MMM d').format(DateTime.parse(item.expiry))}',
                ),
                trailing: IconButton(
                  onPressed: () => vm.removePantry(item.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
        ],
      ],
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.viewModel});
  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final week = List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: 6 - index)),
    );
    final planned = week.fold(
      0,
      (total, day) => total + viewModel.planFor(day).length,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
      children: [
        const ScreenHeading(
          eyebrow: 'YOUR PATTERNS',
          title: 'Weekly insights',
          icon: Icons.donut_large_rounded,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                value: '$planned',
                label: 'Meals planned',
                icon: Icons.calendar_month_rounded,
                color: mint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricTile(
                value: '${viewModel.completedMeals}',
                label: 'Meals enjoyed',
                icon: Icons.check_circle_outline_rounded,
                color: coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                value: '${viewModel.pantry.length}',
                label: 'Pantry items',
                icon: Icons.kitchen_outlined,
                color: gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricTile(
                value: '${viewModel.shopping.where((e) => e.checked).length}',
                label: 'Items checked',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF62B4E6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassPanel(
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SEVEN-DAY ENERGY',
                style: TextStyle(
                  color: mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final day in week)
                      Expanded(
                        child: EnergyBar(
                          date: day,
                          calories: viewModel.caloriesFor(day),
                          target: viewModel.settings.dailyCalories,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (planned == 0) ...[
          const SizedBox(height: 14),
          const Text(
            'Insights are calculated only from meals and items you add.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7C9997), fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class WeekRibbon extends StatelessWidget {
  const WeekRibbon({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final active =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selected);
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              decoration: BoxDecoration(
                color: active ? coral : mint.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? coral : mint.withValues(alpha: .18),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF789795),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: active ? Colors.white : null,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MealSlotTile extends StatelessWidget {
  const MealSlotTile({
    super.key,
    required this.slot,
    required this.item,
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  final MealSlot slot;
  final PlanItem? item;
  final Recipe? recipe;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 20,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: recipe == null
                      ? mint.withValues(alpha: .12)
                      : coral.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  slot == MealSlot.breakfast
                      ? Icons.wb_sunny_outlined
                      : slot == MealSlot.lunch
                      ? Icons.lunch_dining_outlined
                      : slot == MealSlot.dinner
                      ? Icons.nightlight_outlined
                      : Icons.apple_outlined,
                  color: recipe == null ? mint : coral,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.name[0].toUpperCase() + slot.name.substring(1),
                      style: const TextStyle(
                        color: Color(0xFF7C9997),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe?.name ?? 'Add a meal',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (recipe != null)
                      Text(
                        '${recipe!.calories} kcal · ${item!.servings} serving',
                        style: const TextStyle(
                          color: Color(0xFF7C9997),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 19),
                )
              else
                const Icon(Icons.add_rounded, color: mint),
            ],
          ),
        ),
      ),
    );
  }
}

class PlannedMealCard extends StatelessWidget {
  const PlannedMealCard({
    super.key,
    required this.item,
    required this.recipe,
    required this.onToggle,
    required this.onRemove,
  });
  final PlanItem item;
  final Recipe recipe;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 20,
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onToggle,
        leading: Icon(
          item.completed ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: item.completed ? mint : coral,
        ),
        title: Text(
          recipe.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            decoration: item.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${item.slot.name} · ${recipe.minutes} min · ${recipe.calories} kcal',
        ),
        trailing: IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});
  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/recipe_spread.png',
              fit: BoxFit.cover,
              alignment: Alignment(recipe.imageAlignment, 0),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD032A2F)],
                ),
              ),
            ),
            Positioned(
              left: 15,
              right: 15,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.minutes} min · ${recipe.calories} kcal',
                    style: const TextStyle(
                      color: Color(0xFFD2E3DE),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenHeading extends StatelessWidget {
  const ScreenHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.icon,
  });
  final String eyebrow;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: mint.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: mint),
        ),
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7C9997), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class EnergyBar extends StatelessWidget {
  const EnergyBar({
    super.key,
    required this.date,
    required this.calories,
    required this.target,
  });
  final DateTime date;
  final int calories;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 22,
          height: 15 + 105 * (calories / target).clamp(0, 1),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [mint, coral],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('E').format(date).substring(0, 1),
          style: const TextStyle(color: Color(0xFF7C9997), fontSize: 10),
        ),
      ],
    );
  }
}

class EmptyAction extends StatelessWidget {
  const EmptyAction({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 22,
      child: Column(
        children: [
          Icon(icon, color: mint, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7C9997), height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onPressed, child: Text(action)),
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark
                ? const Color(0xC90A2B2E)
                : Colors.white.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: .1)
                  : Colors.white.withValues(alpha: .85),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .18 : .08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

Future<void> showAddMeal(
  BuildContext context,
  AppViewModel viewModel,
  DateTime date,
  MealSlot slot,
) async {
  var selected = recipeCatalog.first;
  var servings = 1;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _Sheet(
        title: 'Add ${slot.name}',
        child: Column(
          children: [
            DropdownButtonFormField<Recipe>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Recipe'),
              items: recipeCatalog
                  .map(
                    (recipe) => DropdownMenuItem(
                      value: recipe,
                      child: Text(recipe.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selected = value!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Servings',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: servings > 1
                      ? () => setState(() => servings--)
                      : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                Text(
                  '$servings',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  onPressed: servings < 8
                      ? () => setState(() => servings++)
                      : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('save-meal'),
                onPressed: () async {
                  await viewModel.addMeal(
                    date: date,
                    slot: slot,
                    selectedRecipe: selected,
                    servings: servings,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add to plan'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showShoppingEditor(
  BuildContext context,
  AppViewModel viewModel,
) async {
  final name = TextEditingController();
  final quantity = TextEditingController();
  var category = 'Produce';
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _Sheet(
        title: 'Add shopping item',
        child: Column(
          children: [
            TextField(
              key: const Key('shopping-name'),
              controller: name,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantity,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Produce', 'Protein', 'Dairy', 'Grains', 'Other']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (name.text.trim().isEmpty) return;
                  await viewModel.addShopping(
                    name: name.text,
                    quantity: quantity.text.trim().isEmpty
                        ? '1'
                        : quantity.text,
                    category: category,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add item'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showPantryEditor(
  BuildContext context,
  AppViewModel viewModel,
) async {
  final name = TextEditingController();
  final quantity = TextEditingController();
  var category = 'Produce';
  var expiry = DateTime.now().add(const Duration(days: 7));
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _Sheet(
        title: 'Add pantry item',
        child: Column(
          children: [
            TextField(
              key: const Key('pantry-name'),
              controller: name,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantity,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Produce', 'Protein', 'Dairy', 'Grains', 'Other']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => category = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: mint.withValues(alpha: .08),
              leading: const Icon(Icons.event_outlined),
              title: const Text('Expiry date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(expiry)),
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  initialDate: expiry,
                );
                if (value != null) setState(() => expiry = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (name.text.trim().isEmpty) return;
                  await viewModel.addPantry(
                    name: name.text,
                    quantity: quantity.text.trim().isEmpty
                        ? '1'
                        : quantity.text,
                    category: category,
                    expiry: expiry,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save to pantry'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showRecipeDetails(BuildContext context, Recipe recipe) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _Sheet(
      title: recipe.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/recipe_spread.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment(recipe.imageAlignment, 0),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${recipe.minutes} min · ${recipe.calories} kcal · ${recipe.protein}g protein',
            style: const TextStyle(color: coral, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final ingredient in recipe.ingredients)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('• $ingredient'),
            ),
          const SizedBox(height: 14),
          const Text(
            'Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < recipe.steps.length; index++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: mint,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: teal),
                ),
              ),
              title: Text(recipe.steps[index]),
            ),
        ],
      ),
    ),
  );
}

Future<void> showProfileScreen(
  BuildContext context,
  AppViewModel viewModel,
) async {
  final name = TextEditingController(text: viewModel.settings.name);
  var diet = viewModel.settings.diet;
  var calories = viewModel.settings.dailyCalories.toDouble();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          appBar: AppBar(title: const Text('Profile & settings')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Your name'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: diet,
                decoration: const InputDecoration(labelText: 'Eating style'),
                items: ['Balanced', 'Vegetarian', 'High protein']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => diet = value!),
              ),
              const SizedBox(height: 18),
              Text('Daily target: ${calories.round()} kcal'),
              Slider(
                value: calories,
                min: 1200,
                max: 3200,
                divisions: 20,
                onChanged: (value) => setState(() => calories = value),
              ),
              const SizedBox(height: 12),
              SegmentedButton<AppThemeChoice>(
                segments: const [
                  ButtonSegment(
                    value: AppThemeChoice.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: AppThemeChoice.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {viewModel.settings.theme},
                onSelectionChanged: (value) => viewModel.setTheme(value.first),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () async {
                  await viewModel.updateProfile(
                    name: name.text,
                    diet: diet,
                    calories: calories.round(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save profile'),
              ),
              TextButton.icon(
                onPressed: () async {
                  await viewModel.resetTutorial();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.school_outlined),
                label: const Text('Replay tutorial'),
              ),
              TextButton.icon(
                onPressed: () async {
                  await dependencies<NotificationService>()
                      .showTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent')),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Send test notification'),
              ),
              const Divider(height: 32),
              OutlinedButton.icon(
                onPressed: () => viewModel.eraseUserData(),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Erase local meal data'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .88,
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xF207282C)
                : const Color(0xF7F7F8F3),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
