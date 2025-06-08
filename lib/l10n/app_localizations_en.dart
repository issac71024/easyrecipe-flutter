// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EasyRecipe';

  @override
  String get searchHint => 'Search recipes...';

  @override
  String get noRecipe => 'No recipes found.';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get formTitle => 'Title';

  @override
  String get formCuisine => 'Cuisine';

  @override
  String get formDiet => 'Diet';

  @override
  String get formSave => 'Save';

  @override
  String get formChooseImage => 'Choose Image';

  @override
  String get formAddRecipeTitle => 'Add a New Recipe';

  @override
  String get cuisineChinese => 'Chinese';

  @override
  String get cuisineJapanese => 'Japanese';

  @override
  String get cuisineWestern => 'Western';

  @override
  String get dietNone => 'None';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietHighProtein => 'High Protein';

  @override
  String get dietLowCarb => 'Low Carb';

  @override
  String get minutes => 'minutes';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get formCookingTime => 'Cooking Time (minutes)';

  @override
  String get formDifficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get formIngredients => 'Ingredients';

  @override
  String get formSteps => 'Steps';

  @override
  String get formTakePhoto => 'Take Photo';

  @override
  String get deleteDialogTitle => 'Delete Recipe';

  @override
  String get deleteDialogContent => 'Are you sure you want to delete this recipe?';

  @override
  String get deleteCancel => 'Cancel';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get formEditRecipeTitle => 'Edit Recipe';

  @override
  String get formSaveSuccess => 'Updated successfully';

  @override
  String get cloudAutoRestore => 'Auto-restored from cloud!';
}
