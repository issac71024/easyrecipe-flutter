import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EasyRecipe'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchHint;

  /// No description provided for @noRecipe.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get noRecipe;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @formTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formTitle;

  /// No description provided for @formCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get formCuisine;

  /// No description provided for @formDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get formDiet;

  /// No description provided for @formSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get formSave;

  /// No description provided for @formChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get formChooseImage;

  /// No description provided for @formAddRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a New Recipe'**
  String get formAddRecipeTitle;

  /// No description provided for @cuisineChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get cuisineChinese;

  /// No description provided for @cuisineJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get cuisineJapanese;

  /// No description provided for @cuisineWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get cuisineWestern;

  /// No description provided for @dietNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get dietNone;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get dietHighProtein;

  /// No description provided for @dietLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get dietLowCarb;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @formCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking Time (minutes)'**
  String get formCookingTime;

  /// No description provided for @formDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get formDifficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @formIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get formIngredients;

  /// No description provided for @formSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get formSteps;

  /// No description provided for @formTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get formTakePhoto;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get deleteDialogContent;

  /// No description provided for @deleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteCancel;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
