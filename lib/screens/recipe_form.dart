import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../l10n/app_localizations.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String cuisine = 'chinese'; // ✅ 預設儲存代碼
  String diet = 'none';
  File? imageFile;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Recipe>('recipes');
      final recipe = Recipe(
        title: title,
        cuisine: cuisine,
        diet: diet,
      );
      await box.add(recipe);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.formAddRecipeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (imageFile != null) Image.file(imageFile!),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(loc.formChooseImage),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formTitle),
                validator: (value) =>
                    value == null || value.isEmpty ? '請輸入標題' : null,
                onChanged: (value) => title = value,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: loc.formCuisine),
                value: cuisine,
                items: [
                  DropdownMenuItem(value: 'chinese', child: Text(loc.cuisineChinese)),
                  DropdownMenuItem(value: 'japanese', child: Text(loc.cuisineJapanese)),
                  DropdownMenuItem(value: 'western', child: Text(loc.cuisineWestern)),
                ],
                onChanged: (value) => setState(() => cuisine = value ?? 'chinese'),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: loc.formDiet),
                value: diet,
                items: [
                  DropdownMenuItem(value: 'none', child: Text(loc.dietNone)),
                  DropdownMenuItem(value: 'vegetarian', child: Text(loc.dietVegetarian)),
                  DropdownMenuItem(value: 'high_protein', child: Text(loc.dietHighProtein)),
                  DropdownMenuItem(value: 'low_carb', child: Text(loc.dietLowCarb)),
                ],
                onChanged: (value) => setState(() => diet = value ?? 'none'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(loc.formSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}