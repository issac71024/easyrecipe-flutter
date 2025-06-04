import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
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