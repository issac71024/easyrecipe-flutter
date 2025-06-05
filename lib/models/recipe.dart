// lib/models/recipe.dart
import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String cuisine;

  @HiveField(2)
  String diet;

  Recipe({required this.title, required this.cuisine, required this.diet});
}