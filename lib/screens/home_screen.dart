import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';
import 'recipe_form.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const HomeScreen({super.key, required this.onLocaleChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recipeBox = Hive.box<Recipe>('recipes');
  String searchTerm = '';

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
        title: Text(loc.appTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'en') {
                widget.onLocaleChange(const Locale('en'));
              } else if (value == 'zh') {
                widget.onLocaleChange(const Locale('zh'));
              }
            },
            icon: const Icon(Icons.language),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'zh', child: Text('繁體中文')),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: recipeBox.listenable(),
        builder: (context, Box<Recipe> box, _) {
          final isZh = Localizations.localeOf(context).languageCode == 'zh';
          final searchLower = searchTerm.toLowerCase();
          final filtered = box.values.where((recipe) {
            final title = isZh ? recipe.titleZh : recipe.titleEn;
            return
              title.toLowerCase().contains(searchLower) ||
              recipe.ingredients.toLowerCase().contains(searchLower) ||
              recipe.cookingTime.toString().contains(searchLower);
          }).toList();

          if (filtered.isEmpty) {
            return Center(child: Text(loc.noRecipe));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final recipe = filtered[index];
              return ListTile(
                leading: (recipe.imagePath != null && recipe.imagePath!.isNotEmpty)
                  ? Image.file(
                      File(recipe.imagePath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported, size: 40),
                title: Text(isZh ? recipe.titleZh : recipe.titleEn),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translateCuisine(loc)[recipe.cuisine] ?? recipe.cuisine} • '
                      '${translateDiet(loc)[recipe.diet] ?? recipe.diet}',
                    ),
                    Text(
                      '⏱️ ${recipe.cookingTime} ${loc.minutes} • '
                      '${loc.difficultyLabel}：${_translateDifficulty(recipe.difficulty, loc)}',
                    ),
                    if (recipe.ingredients.isNotEmpty)
                      Text('📋 材料：${recipe.ingredients}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeFormScreen(recipe: recipe),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
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
                      await recipe.delete();
                      setState(() {});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
