import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../l10n/app_localizations.dart';
import 'recipe_form.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isZh;
  const RecipeDetailScreen({super.key, required this.recipe, required this.isZh});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Map<String, String> translateCuisine(AppLocalizations loc) => {
    'chinese': loc.cuisineChinese,
    'japanese': loc.cuisineJapanese,
    'western': loc.cuisineWestern,
  };

  Map<String, String> translateDiet(AppLocalizations loc) => {
    'none': loc.dietNone,
    'vegetarian': loc.dietVegetarian,
    'high_protein': loc.dietHighProtein,
    'low_carb': loc.dietLowCarb,
  };

  String _translateDifficulty(String code, AppLocalizations loc) {
    switch (code) {
      case 'easy': return loc.difficultyEasy;
      case 'medium': return loc.difficultyMedium;
      case 'hard': return loc.difficultyHard;
      default: return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isZh ? _recipe.titleZh : _recipe.titleEn),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: loc.formEditRecipeTitle ?? '編輯',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormScreen(recipe: _recipe),
                ),
              );
              if (updated == true) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.formSaveSuccess ?? '已更新')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: loc.deleteConfirm,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(loc.deleteDialogTitle),
                  content: Text(loc.deleteDialogContent),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(loc.deleteCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(loc.deleteConfirm),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _recipe.delete();
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_recipe.imagePath != null && _recipe.imagePath!.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(),
                      backgroundColor: Colors.black,
                      body: Center(
                        child: Image.file(File(_recipe.imagePath!), fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
              child: Image.file(File(_recipe.imagePath!), height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Text('${loc.formCuisine}：${translateCuisine(loc)[_recipe.cuisine] ?? _recipe.cuisine}'),
          Text('${loc.formDiet}：${translateDiet(loc)[_recipe.diet] ?? _recipe.diet}'),
          Text('${loc.formCookingTime}：${_recipe.cookingTime} ${loc.minutes}'),
          Text('${loc.formDifficulty}：${_translateDifficulty(_recipe.difficulty, loc)}'),
          const Divider(),
          Text('${loc.formIngredients}：\n${_recipe.ingredients}'),
          const SizedBox(height: 8),
          Text('${loc.formSteps}：\n${_recipe.steps}'),
        ],
      ),
    );
  }
}
