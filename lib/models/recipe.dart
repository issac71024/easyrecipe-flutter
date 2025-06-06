import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String titleZh;

  @HiveField(1)
  String titleEn;

  @HiveField(2)
  String cuisine;

  @HiveField(3)
  String diet;

  @HiveField(4)
  int cookingTime;

  @HiveField(5)
  String difficulty;

  @HiveField(6)
  String ingredients;

  @HiveField(7)
  String steps;

  @HiveField(8)
  String? imagePath;

Recipe({
    required this.titleZh,
    required this.titleEn,
    required this.cuisine,
    required this.diet,
    required this.cookingTime,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    this.imagePath,
  });
}