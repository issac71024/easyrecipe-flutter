import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipes');

  runApp(const EasyRecipeApp());
}

class EasyRecipeApp extends StatefulWidget {
  const EasyRecipeApp({super.key});

  @override
  State<EasyRecipeApp> createState() => _EasyRecipeAppState();
}

class _EasyRecipeAppState extends State<EasyRecipeApp> {
  Locale _locale = const Locale('zh'); // 預設為繁體中文

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(onLocaleChange: _changeLanguage),
    );
  }
}