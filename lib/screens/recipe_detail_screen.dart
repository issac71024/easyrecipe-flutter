import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    'vegan': loc.dietVegan,
    'gluten_free': loc.dietGlutenFree,
    'custom': loc.dietCustom,
  };

  String _translateDifficulty(String code, AppLocalizations loc) {
    switch (code) {
      case 'easy': return loc.difficultyEasy;
      case 'medium': return loc.difficultyMedium;
      case 'hard': return loc.difficultyHard;
      default: return code;
    }
  }

  Widget get weatherCard => WeatherCard(isZh: widget.isZh);

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
                        child: _recipe.imagePath!.startsWith('assets/')
                            ? Image.asset(_recipe.imagePath!, fit: BoxFit.contain)
                            : Image.file(File(_recipe.imagePath!), fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
              child: _recipe.imagePath!.startsWith('assets/')
                  ? Image.asset(_recipe.imagePath!, height: 200, fit: BoxFit.cover)
                  : Image.file(File(_recipe.imagePath!), height: 200, fit: BoxFit.cover),
            ),
          // Weather Card
          weatherCard,
          const SizedBox(height: 12),
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

// Weather Card & suggestion
class WeatherCard extends StatefulWidget {
  final bool isZh;
  const WeatherCard({Key? key, required this.isZh}) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Map<String, dynamic>? weather;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=22.3027&longitude=114.1772&current_weather=true';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          weather = data['current_weather'];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  // Base on weather suggestion
  Map<String, dynamic> _getSuggestion(num? temp, bool isZh) {
    if (temp == null) {
      return {
        "suggest": isZh ? "保持心情愉快，享受每一餐！" : "Enjoy your meal and stay positive!",
        "dish": isZh ? "任何料理" : "Any dish",
        "icon": Icons.emoji_emotions,
      };
    }
    if (temp >= 30) {
      return {
        "suggest": isZh ? "天氣炎熱，來點清爽涼拌或冷麵吧！" : "It's hot! How about something cold and refreshing?",
        "dish": isZh ? "冷麵、沙律、涼拌" : "Cold noodles, salad, chilled dishes",
        "icon": Icons.ac_unit,
      };
    } else if (temp >= 22) {
      return {
        "suggest": isZh ? "天氣溫暖，輕食或快炒最適合。" : "Warm weather, try light meals or stir fry.",
        "dish": isZh ? "炒菜、便當、壽司" : "Stir fry, bento, sushi",
        "icon": Icons.wb_sunny,
      };
    } else {
      return {
        "suggest": isZh ? "天氣涼快，煲湯或熱飯暖胃！" : "Cooler day, warm soup or hearty meals recommended!",
        "dish": isZh ? "燉湯、火鍋、燒肉" : "Soup, hotpot, grilled dishes",
        "icon": Icons.local_fire_department,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZh = widget.isZh;
    if (loading) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(isZh ? "載入天氣資訊中..." : "Loading weather..."),
            ],
          ),
        ),
      );
    }
    if (weather == null) return const SizedBox.shrink();

    final temp = weather!['temperature'] as num?;
    final info = _getSuggestion(temp, isZh);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.lightBlue.shade50,
      child: ListTile(
        leading: Icon(info['icon'], color: Colors.blue, size: 36),
        title: Text(isZh ? "香港即時天氣" : "HK Weather"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isZh
                  ? "氣溫：${temp?.toStringAsFixed(1) ?? '--'}°C"
                  : "Temperature: ${temp?.toStringAsFixed(1) ?? '--'}°C") +
                  (weather!['windspeed'] != null
                      ? (isZh
                          ? "　風速：${weather!['windspeed']} km/h"
                          : "   Wind: ${weather!['windspeed']} km/h")
                      : ""),
            ),
            const SizedBox(height: 4),
            Text(
              isZh
                  ? "料理建議：${info['dish']}"
                  : "Suggested dishes: ${info['dish']}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              info['suggest'],
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.brown),
            ),
          ],
        ),
      ),
    );
  }
}
