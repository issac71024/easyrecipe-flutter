import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  Locale _locale = const Locale('zh'); 
  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  void dispose() {
    isDarkMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
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
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            fontFamily: 'Nunito',
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.dark,
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
          ),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(
            onLocaleChange: _changeLanguage,
            isDarkMode: isDarkMode, 
          ),
        );
      },
    );
  }
}
