import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/recipe.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipes');

  runApp(const EasyRecipeApp());
}

class EasyRecipeApp extends StatelessWidget {
  const EasyRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRecipe',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}