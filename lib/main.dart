import 'package:flutter/material.dart';

void main() {
  runApp(const EasyRecipeApp());
}

class EasyRecipeApp extends StatelessWidget {
  const EasyRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRecipe',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to EasyRecipe! Phase 1 Initialized.'),
        ),
      ),
    );
  }
}
