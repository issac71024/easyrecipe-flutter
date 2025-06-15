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

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietKeto => 'Keto';

  @override
  String get dietPaleo => 'Paleo';

  @override
  String get dietOther => 'Other / 其他';

  @override
  String get dietGlutenFree => 'Gluten Free';

  @override
  String get dietCustom => 'Custom';

  @override
  String get onboardTitle1 => 'Welcome to EasyRecipe';

  @override
  String get onboardDesc1 => 'Manage your recipes, photos, and cloud backup easily.';

  @override
  String get onboardTitle2 => 'Add New Recipe';

  @override
  String get onboardDesc2 => 'Tap the + button to quickly add your favorite recipe.';

  @override
  String get onboardTitle3 => 'Google Login & Sync';

  @override
  String get onboardDesc3 => 'Login with Google for secure cloud sync and backup.';

  @override
  String get onboardStart => 'Start';

  @override
  String get next => 'Next';

  @override
  String get about => 'About/Settings';

  @override
  String get aboutDesc => 'Local storage (Hive) & Cloud sync (Firestore). Google sign-in, multi-language.';

  @override
  String get author => 'Author';

  @override
  String get version => 'Version';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get aboutDetail => 'Recipes are securely saved locally with Hive encryption. When you sign in with Google, your data is synced to Firestore cloud. This app is for academic use only.';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get darkMode => 'Dark Mode';
}
