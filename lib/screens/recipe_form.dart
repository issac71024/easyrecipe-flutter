import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../l10n/app_localizations.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;
  const RecipeFormScreen({Key? key, this.recipe}) : super(key: key);

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String titleZh;
  late String titleEn;
  late String cuisine;
  late String diet;
  late int cookingTime;
  late String difficulty;
  late String ingredients;
  late String steps;
  File? imageFile;
  String? imagePath;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    titleZh = r?.titleZh ?? '';
    titleEn = r?.titleEn ?? '';
    cuisine = r?.cuisine ?? 'chinese';
    diet = r?.diet ?? 'none';
    cookingTime = r?.cookingTime ?? 0;
    difficulty = r?.difficulty ?? 'easy';
    ingredients = r?.ingredients ?? '';
    steps = r?.steps ?? '';
    imagePath = r?.imagePath;
    if (imagePath != null) imageFile = File(imagePath!);
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        imagePath = picked.path;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        imagePath = picked.path;
      });
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Recipe>('recipes');
      if (widget.recipe == null) {
        final recipe = Recipe(
          titleZh: titleZh,
          titleEn: titleEn,
          cuisine: cuisine,
          diet: diet,
          cookingTime: cookingTime,
          difficulty: difficulty,
          ingredients: ingredients,
          steps: steps,
          imagePath: imageFile?.path,
        );
        await box.add(recipe);
      } else {
        widget.recipe!
          ..titleZh = titleZh
          ..titleEn = titleEn
          ..cuisine = cuisine
          ..diet = diet
          ..cookingTime = cookingTime
          ..difficulty = difficulty
          ..ingredients = ingredients
          ..steps = steps
          ..imagePath = imageFile?.path;
        await widget.recipe!.save();
      }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.image),
                    label: Text(loc.formChooseImage),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(loc.formTakePhoto),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formTitle + '（繁體中文）'),
                validator: (value) => value == null || value.isEmpty ? '請輸入標題' : null,
                onChanged: (value) => titleZh = value,
                initialValue: titleZh,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formTitle + ' (English)'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
                onChanged: (value) => titleEn = value,
                initialValue: titleEn,
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
              TextFormField(
                decoration: InputDecoration(labelText: loc.formCookingTime),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return '請輸入時間';
                  if (int.tryParse(value) == null) return '請輸入有效數字';
                  return null;
                },
                onChanged: (value) => cookingTime = int.tryParse(value) ?? 0,
                initialValue: cookingTime > 0 ? cookingTime.toString() : '',
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: loc.formDifficulty),
                value: difficulty,
                items: [
                  DropdownMenuItem(value: 'easy', child: Text(loc.difficultyEasy)),
                  DropdownMenuItem(value: 'medium', child: Text(loc.difficultyMedium)),
                  DropdownMenuItem(value: 'hard', child: Text(loc.difficultyHard)),
                ],
                onChanged: (value) => setState(() => difficulty = value ?? 'easy'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formIngredients),
                maxLines: 3,
                onChanged: (value) => ingredients = value,
                initialValue: ingredients,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formSteps),
                maxLines: 5,
                onChanged: (value) => steps = value,
                initialValue: steps,
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
