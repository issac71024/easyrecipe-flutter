import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('>>> 準備初始化 Firebase');
  await Firebase.initializeApp();
  print('>>> Firebase 初始化完成');
  await Hive.initFlutter();
  print('>>> Hive 初始化完成');
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipes');
  print('>>> Hive box 開啟完成，準備 runApp');
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
