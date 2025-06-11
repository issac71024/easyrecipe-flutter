import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../l10n/app_localizations.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;
  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String titleZh;
  late String titleEn;
  late String cuisine;
  late String diet;
  late String customDiet; // for "other"
  late int cookingTime;
  late String difficulty;
  late String ingredients;
  late String steps;
  File? imageFile;
  String? imagePath;

  final picker = ImagePicker();
  final _customDietController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    titleZh = r?.titleZh ?? '';
    titleEn = r?.titleEn ?? '';
    cuisine = r?.cuisine ?? 'chinese';
    diet = r?.diet ?? 'none';
    customDiet = r?.diet != null && _dietOptions.contains(r!.diet) ? '' : r?.diet ?? '';
    _customDietController.text = customDiet;
    cookingTime = r?.cookingTime ?? 0;
    difficulty = r?.difficulty ?? 'easy';
    ingredients = r?.ingredients ?? '';
    steps = r?.steps ?? '';
    imagePath = r?.imagePath ?? '';
    if (imagePath != null && imagePath!.isNotEmpty) {
      imageFile = File(imagePath!);
    }
  }

  static const _dietOptions = [
    'none',
    'vegetarian',
    'vegan',
    'high_protein',
    'low_carb',
    'keto',
    'paleo',
    'other',
  ];

  Map<String, String> dietLabels(AppLocalizations loc) => {
    'none': loc.dietNone,
    'vegetarian': loc.dietVegetarian,
    'vegan': loc.dietVegan,
    'high_protein': loc.dietHighProtein,
    'low_carb': loc.dietLowCarb,
    'keto': loc.dietKeto,
    'paleo': loc.dietPaleo,
    'other': loc.dietOther,
  };

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

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Recipe>('recipes');
      String saveDiet;
      if (diet == 'other') {
        saveDiet = _customDietController.text.trim();
      } else {
        saveDiet = diet;
      }

      if (widget.recipe != null) {
        widget.recipe!
          ..titleZh = titleZh
          ..titleEn = titleEn
          ..cuisine = cuisine
          ..diet = saveDiet
          ..cookingTime = cookingTime
          ..difficulty = difficulty
          ..ingredients = ingredients
          ..steps = steps
          ..imagePath = imagePath ?? '';
        await widget.recipe!.save();
        Navigator.pop(context, true);
      } else {
        final recipe = Recipe(
          titleZh: titleZh,
          titleEn: titleEn,
          cuisine: cuisine,
          diet: saveDiet,
          cookingTime: cookingTime,
          difficulty: difficulty,
          ingredients: ingredients,
          steps: steps,
          imagePath: imagePath ?? '',
        );
        await box.add(recipe);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _customDietController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeColor = const Color(0xFFB17250);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null
            ? loc.formAddRecipeTitle
            : loc.formEditRecipeTitle ?? '編輯食譜'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (imageFile != null)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          backgroundColor: Colors.black,
                          body: Center(
                            child: Image.file(imageFile!, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.file(imageFile!, height: 180, fit: BoxFit.cover),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.image),
                    label: Text(loc.formChooseImage),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(loc.formTakePhoto),
                  ),
                ],
              ),
              // CH OR ENG
              TextFormField(
                decoration: InputDecoration(labelText: '${loc.formTitle}（繁體中文）'),
                initialValue: titleZh,
                onChanged: (value) => titleZh = value,
                validator: (value) {
                  if ((value == null || value.isEmpty) && (titleEn.isEmpty)) {
                    return '請至少輸入一個標題';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${loc.formTitle} (English)'),
                initialValue: titleEn,
                onChanged: (value) => titleEn = value,
                validator: (value) {
                  if ((value == null || value.isEmpty) && (titleZh.isEmpty)) {
                    return 'Please enter at least one title';
                  }
                  return null;
                },
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
                value: _dietOptions.contains(diet) ? diet : 'other',
                items: _dietOptions.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(dietLabels(loc)[value]!),
                  );
                }).toList(),
                onChanged: (value) => setState(() => diet = value ?? 'none'),
              ),
              if (diet == 'other')
                TextFormField(
                  controller: _customDietController,
                  decoration: const InputDecoration(labelText: '自訂飲食分類 (Diet)'),
                  validator: (value) {
                    if (diet == 'other' && (value == null || value.isEmpty)) {
                      return '請輸入飲食分類';
                    }
                    return null;
                  },
                ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formCookingTime),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return '請輸入時間';
                  if (int.tryParse(value) == null) return '請輸入有效數字';
                  return null;
                },
                initialValue: cookingTime == 0 ? '' : cookingTime.toString(),
                onChanged: (value) => cookingTime = int.tryParse(value) ?? 0,
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
                initialValue: ingredients,
                onChanged: (value) => ingredients = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: loc.formSteps),
                maxLines: 5,
                initialValue: steps,
                onChanged: (value) => steps = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
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
