// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '簡易食譜';

  @override
  String get searchHint => '搜尋食譜...';

  @override
  String get noRecipe => '找不到食譜';

  @override
  String get addRecipe => '新增食譜';

  @override
  String get formTitle => '標題';

  @override
  String get formCuisine => '料理類型';

  @override
  String get formDiet => '飲食分類';

  @override
  String get formSave => '儲存';

  @override
  String get formChooseImage => '選擇圖片';

  @override
  String get formAddRecipeTitle => '新增一筆食譜';

  @override
  String get cuisineChinese => '中式';

  @override
  String get cuisineJapanese => '日式';

  @override
  String get cuisineWestern => '西式';

  @override
  String get dietNone => '無';

  @override
  String get dietVegetarian => '素食';

  @override
  String get dietHighProtein => '高蛋白';

  @override
  String get dietLowCarb => '低醣';
}
