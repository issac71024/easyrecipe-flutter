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
  String get dietLowCarb => '低碳';

  @override
  String get minutes => '分鐘';

  @override
  String get difficultyLabel => '難度';

  @override
  String get formCookingTime => '烹飪時間（分鐘）';

  @override
  String get formDifficulty => '難度';

  @override
  String get difficultyEasy => '簡單';

  @override
  String get difficultyMedium => '中等';

  @override
  String get difficultyHard => '困難';

  @override
  String get formIngredients => '材料';

  @override
  String get formSteps => '步驟';

  @override
  String get formTakePhoto => '拍照';

  @override
  String get deleteDialogTitle => '刪除食譜';

  @override
  String get deleteDialogContent => '你確定要刪除此食譜嗎？';

  @override
  String get deleteCancel => '取消';

  @override
  String get deleteConfirm => '刪除';

  @override
  String get formEditRecipeTitle => '編輯食譜';

  @override
  String get formSaveSuccess => '已成功更新';

  @override
  String get cloudAutoRestore => '已自動從雲端同步';

  @override
  String get dietVegan => '全素';

  @override
  String get dietKeto => '生酮';

  @override
  String get dietPaleo => '原始人飲食';

  @override
  String get dietOther => '其他 / Other';

  @override
  String get dietGlutenFree => '無麩質';

  @override
  String get dietCustom => '自訂';

  @override
  String get onboardTitle1 => '歡迎使用簡易食譜';

  @override
  String get onboardDesc1 => '輕鬆管理食譜、照片與雲端備份。';

  @override
  String get onboardTitle2 => '新增料理';

  @override
  String get onboardDesc2 => '點選右下 + 按鈕即可快速新增您的最愛食譜。';

  @override
  String get onboardTitle3 => 'Google 登入與同步';

  @override
  String get onboardDesc3 => '使用 Google 登入，保證資料安全同步雲端。';

  @override
  String get onboardStart => '開始使用';

  @override
  String get next => '下一步';

  @override
  String get about => '關於/設定';

  @override
  String get aboutDesc => '簡易食譜 EasyRecipe 幫你管理和備份個人食譜，支援多語、雲端同步、Google 登入，以及拍照上傳，簡單易用。';

  @override
  String get author => '作者';

  @override
  String get version => '版本';

  @override
  String get theme => '主題';

  @override
  String get dark => '深色';

  @override
  String get light => '淺色';

  @override
  String get aboutDetail => '本 App 採用本地加密與雲端 Firestore，登入 Google 自動同步。';

  @override
  String get settings => '設定';

  @override
  String get logout => '登出';

  @override
  String get darkMode => '夜間模式';
}
