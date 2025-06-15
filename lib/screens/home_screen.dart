import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import 'recipe_form.dart';
import '../l10n/app_localizations.dart';
import 'recipe_detail_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  final ValueNotifier<bool> isDarkMode;
  const HomeScreen({
    super.key,
    required this.onLocaleChange,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recipeBox = Hive.box<Recipe>('recipes');
  String searchTerm = '';
  User? _user;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _showOnboardingIfFirstLaunch();
    _autoRestoreFromCloud();
    _insertSampleRecipesIfEmpty();
  }

  Future<void> _insertSampleRecipesIfEmpty() async {
    final box = Hive.box<Recipe>('recipes');
    if (box.isEmpty) {
      final samples = [
  Recipe(
    titleZh: "日式照燒雞腿飯",
    titleEn: "Japanese Teriyaki Chicken Bowl",
    cuisine: "japanese",
    diet: "high_protein",
    cookingTime: 30,
    difficulty: "medium",
    ingredients: "雞腿排、醬油、味醂、米酒、糖、白飯",
    steps: "1. 雞腿煎香\n2. 下醬汁煮收汁\n3. 盛飯淋汁",
    imagePath: "assets/sample1.jpg",
  ),
  Recipe(
    titleZh: "番茄炒蛋",
    titleEn: "Tomato Scrambled Eggs",
    cuisine: "chinese",
    diet: "vegetarian",
    cookingTime: 10,
    difficulty: "easy",
    ingredients: "番茄、雞蛋、蔥、鹽",
    steps: "1. 番茄切塊\n2. 蛋炒熟備用\n3. 炒番茄後回鍋蛋",
    imagePath: "assets/sample2.jpg",
  ),
  Recipe(
    titleZh: "美式鬆餅",
    titleEn: "American Pancakes",
    cuisine: "western",
    diet: "none",
    cookingTime: 25,
    difficulty: "easy",
    ingredients: "麵粉、牛奶、蛋、糖、泡打粉、奶油",
    steps: "1. 混合粉類\n2. 加蛋牛奶拌勻\n3. 小火煎至金黃",
    imagePath: "assets/sample3.jpg",
  ),
  Recipe(
    titleZh: "健康藜麥沙拉",
    titleEn: "Healthy Quinoa Salad",
    cuisine: "western",
    diet: "vegan",
    cookingTime: 15,
    difficulty: "easy",
    ingredients: "藜麥、小黃瓜、蕃茄、檸檬、橄欖油、黑胡椒",
    steps: "1. 藜麥煮熟放涼\n2. 蔬菜切丁拌勻\n3. 加檸檬汁橄欖油調味",
    imagePath: "assets/sample4.jpg",
  ),
  Recipe(
    titleZh: "麻婆豆腐",
    titleEn: "Mapo Tofu",
    cuisine: "chinese",
    diet: "none",
    cookingTime: 20,
    difficulty: "medium",
    ingredients: "嫩豆腐、豬絞肉、豆瓣醬、蔥、薑、蒜",
    steps: "1. 爆香蔥薑蒜\n2. 下絞肉炒香\n3. 加豆腐及調味料煮滾",
    imagePath: "assets/sample5.jpg",
  ),
  Recipe(
    titleZh: "日式玉子燒",
    titleEn: "Japanese Tamagoyaki",
    cuisine: "japanese",
    diet: "vegetarian",
    cookingTime: 12,
    difficulty: "medium",
    ingredients: "雞蛋、糖、醬油、鹽",
    steps: "1. 蛋液調味\n2. 分次煎成層\n3. 捲起切片",
    imagePath: "assets/sample6.jpg",
  ),
  Recipe(
    titleZh: "香煎三文魚",
    titleEn: "Pan-Seared Salmon",
    cuisine: "western",
    diet: "high_protein",
    cookingTime: 18,
    difficulty: "easy",
    ingredients: "三文魚、橄欖油、檸檬、鹽、黑胡椒",
    steps: "1. 魚排兩面煎熟\n2. 檸檬汁調味\n3. 盛盤撒胡椒",
    imagePath: "assets/sample7.jpg",
  ),
  Recipe(
    titleZh: "和風牛肉丼",
    titleEn: "Gyudon (Japanese Beef Bowl)",
    cuisine: "japanese",
    diet: "none",
    cookingTime: 20,
    difficulty: "medium",
    ingredients: "牛肉片、洋蔥、醬油、味醂、白飯",
    steps: "1. 洋蔥炒軟\n2. 牛肉快炒\n3. 加醬汁盛飯上",
    imagePath: "assets/sample8.jpg",
  ),
  Recipe(
    titleZh: "西式蔬菜湯",
    titleEn: "Western Vegetable Soup",
    cuisine: "western",
    diet: "vegan",
    cookingTime: 30,
    difficulty: "easy",
    ingredients: "番茄、胡蘿蔔、馬鈴薯、洋蔥、芹菜、鹽",
    steps: "1. 蔬菜切塊\n2. 煮湯至軟爛\n3. 加鹽調味",
    imagePath: "assets/sample9.jpg",
  ),
  Recipe(
    titleZh: "可可布朗尼",
    titleEn: "Chocolate Brownies",
    cuisine: "western",
    diet: "none",
    cookingTime: 35,
    difficulty: "medium",
    ingredients: "黑巧克力、奶油、蛋、糖、麵粉、可可粉",
    steps: "1. 巧克力奶油隔水融化\n2. 拌入蛋糖粉類\n3. 烤箱烘烤25分鐘",
    imagePath: "assets/sample10.jpg",
  ),
      ];
      for (final r in samples) {
        await box.add(r);
      }
      setState(() {});
    }
  }

  Future<void> _showOnboardingIfFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seenOnboarding') ?? false;
    if (!seen) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              onFinish: () async {
                await prefs.setBool('seenOnboarding', true);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    }
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
      case 'easy':
        return loc.difficultyEasy;
      case 'medium':
        return loc.difficultyMedium;
      case 'hard':
        return loc.difficultyHard;
      default:
        return code;
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });
      await _autoRestoreFromCloud();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google 登入失敗: $e")),
      );
    }
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    final box = Hive.box<Recipe>('recipes');
    await box.clear();
    setState(() {
      _user = null;
    });
  }

  Future<void> _autoRestoreFromCloud() async {
    if (_user == null) return;
    final uid = _user!.uid;
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').doc(uid).collection('recipes').get();
    final box = Hive.box<Recipe>('recipes');
    await box.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final recipe = Recipe(
        titleZh: data['titleZh'] ?? '',
        titleEn: data['titleEn'] ?? '',
        cuisine: data['cuisine'] ?? '',
        diet: data['diet'] ?? '',
        cookingTime: data['cookingTime'] ?? 0,
        difficulty: data['difficulty'] ?? '',
        ingredients: data['ingredients'] ?? '',
        steps: data['steps'] ?? '',
        imagePath: data['imagePath'] ?? '',
      );
      await box.add(recipe);
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已自動還原雲端食譜')),
    );
  }

  Future<void> _autoBackupToCloud() async {
    if (_user == null || _isBackingUp) return;
    _isBackingUp = true;
    final uid = _user!.uid;
    final recipes = recipeBox.values.toList();
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final userCollection = firestore.collection('users').doc(uid).collection('recipes');
    final oldDocs = await userCollection.get();
    for (var doc in oldDocs.docs) {
      batch.delete(doc.reference);
    }
    for (var recipe in recipes) {
      final doc = userCollection.doc(recipe.key.toString());
      batch.set(doc, {
        'titleZh': recipe.titleZh,
        'titleEn': recipe.titleEn,
        'cuisine': recipe.cuisine,
        'diet': recipe.diet,
        'cookingTime': recipe.cookingTime,
        'difficulty': recipe.difficulty,
        'ingredients': recipe.ingredients,
        'steps': recipe.steps,
        'imagePath': recipe.imagePath,
      });
    }
    await batch.commit();
    _isBackingUp = false;
  }

  Future<void> _backupToCloud() async {
    await _autoBackupToCloud();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('備份完成（雲端 Firestore）')),
    );
  }

  Future<void> _restoreFromCloud() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登入 Google 帳號')),
      );
      return;
    }
    final uid = _user!.uid;
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('users').doc(uid).collection('recipes').get();
    final box = Hive.box<Recipe>('recipes');
    await box.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final recipe = Recipe(
        titleZh: data['titleZh'] ?? '',
        titleEn: data['titleEn'] ?? '',
        cuisine: data['cuisine'] ?? '',
        diet: data['diet'] ?? '',
        cookingTime: data['cookingTime'] ?? 0,
        difficulty: data['difficulty'] ?? '',
        ingredients: data['ingredients'] ?? '',
        steps: data['steps'] ?? '',
        imagePath: data['imagePath'] ?? '',
      );
      await box.add(recipe);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('還原完成（雲端 Firestore）')),
    );
    setState(() {});
  }

  Widget recipeImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        width: 74,
        height: 74,
        color: Colors.teal.shade50,
        child: const Icon(Icons.image_outlined, color: Colors.teal, size: 36),
      );
    }
    if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(path, width: 74, height: 74, fit: BoxFit.cover),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(File(path), width: 74, height: 74, fit: BoxFit.cover),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations loc) {
    showAboutDialog(
      context: context,
      applicationName: loc.appTitle,
      applicationVersion: "1.0.0",
      applicationLegalese: "Copyright © 2025 Issac Cheng",
      children: [
        const SizedBox(height: 16),
        Text(
          loc.aboutDetail ?? "食譜本地儲存支援 Hive 加密，Google 登入後資料自動安全同步雲端 Firestore。\n\n本應用程式僅供學術用途。",
          style: GoogleFonts.nunito(fontSize: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeColor = const Color(0xFFB17250);
    final themeGradient = LinearGradient(
      colors: [
        themeColor,
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.brown.shade200,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: themeGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: themeGradient,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        Localizations.localeOf(context).languageCode == 'zh'
                            ? 'assets/logo_zh.png'
                            : 'assets/logo_en.png',
                        height: 44,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.appTitle,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(loc.about ?? '關於/設定'),
                  onTap: () => _showAboutDialog(context, loc),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(loc.settings ?? '設定'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(isDarkMode: widget.isDarkMode),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true, 
  title: FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      loc.appTitle,
      style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  ),
  actions: [
    if (_user != null)
      PopupMenuButton<String>(
        offset: const Offset(0, 48),
        tooltip: _user!.displayName ?? 'Account',
        icon: _user!.photoURL != null && _user!.photoURL!.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(_user!.photoURL!),
                radius: 18,
              )
            : CircleAvatar(
                backgroundColor: Colors.brown.shade200,
                radius: 18,
                child: Text(
                  (_user!.displayName ?? '').isNotEmpty
                      ? _user!.displayName![0].toUpperCase()
                      : '?',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                Icon(Icons.account_circle, color: themeColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _user!.displayName ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                const SizedBox(width: 6),
                Text(loc.logout ?? "登出"),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'logout') _signOut();
        },
      )
    else
      IconButton(
        icon: const Icon(Icons.login),
        tooltip: 'Google 登入',
        onPressed: _signInWithGoogle,
      ),
    IconButton(
      icon: const Icon(Icons.cloud_upload),
      tooltip: '雲端備份',
      onPressed: _backupToCloud,
    ),
    IconButton(
      icon: const Icon(Icons.cloud_download),
      tooltip: '從雲端還原',
      onPressed: _restoreFromCloud,
    ),
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
    ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: loc.searchHint,
          hintStyle: GoogleFonts.nunito(
              color: isDark ? Colors.teal.shade100 : Colors.teal.shade800),
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.teal.shade100 : Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        ),
        style: GoogleFonts.nunito(fontSize: 16, color: isDark ? Colors.white : Colors.black),
        onChanged: (value) {
          setState(() {
            searchTerm = value;
          });
        },
      ),
    ),
  ),
),

        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ValueListenableBuilder(
            valueListenable: recipeBox.listenable(),
            builder: (context, Box<Recipe> box, _) {
              _autoBackupToCloud();

              final isZh = Localizations.localeOf(context).languageCode == 'zh';
              final searchLower = searchTerm.toLowerCase();
              final filtered = box.values.where((recipe) {
                if (isZh && recipe.titleZh.trim().isEmpty) return false;
                if (!isZh && recipe.titleEn.trim().isEmpty) return false;
                final title = isZh ? recipe.titleZh : recipe.titleEn;
                return title.toLowerCase().contains(searchLower) ||
                    recipe.ingredients.toLowerCase().contains(searchLower) ||
                    recipe.cookingTime.toString().contains(searchLower);
              }).toList();

              if (filtered.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_food_beverage,
                              color: Colors.teal.shade100, size: 88),
                          const SizedBox(height: 18),
                          Text(
                            loc.noRecipe,
                            style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filtered.length,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                itemBuilder: (context, index) {
                  final recipe = filtered[index];
                  return Card(
                    elevation: 7,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(
                              recipe: recipe,
                              isZh: isZh,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [Colors.grey.shade900, Colors.grey.shade800]
                                : [Colors.brown.shade50, Colors.brown.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              recipeImage(recipe.imagePath),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isZh ? recipe.titleZh : recipe.titleEn,
                                      style: GoogleFonts.nunito(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.brown.shade50
                                            : Colors.brown.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        Icon(Icons.restaurant_menu,
                                            color: Colors.teal.shade200,
                                            size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${translateCuisine(loc)[recipe.cuisine] ?? recipe.cuisine} • ${translateDiet(loc)[recipe.diet] ?? recipe.diet}',
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.teal.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 8, top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors:
                                                  recipe.difficulty == 'easy'
                                                      ? [Colors.green.shade200, Colors.green.shade400]
                                                      : recipe.difficulty == 'medium'
                                                          ? [Colors.orange.shade200, Colors.orange]
                                                          : [Colors.red.shade200, Colors.red],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _translateDifficulty(recipe.difficulty, loc),
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.schedule,
                                            size: 15, color: Colors.grey.shade500),
                                        Text(
                                          ' ${recipe.cookingTime} ${loc.minutes}',
                                          style: GoogleFonts.inter(
                                              fontSize: 13, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    if (recipe.ingredients.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '📋 ${recipe.ingredients}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                              fontSize: 13, color: Colors.grey[700]),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.deleteDialogTitle),
                                      content: Text(loc.deleteDialogContent),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(loc.deleteCancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 10, right: 6),
          child: FloatingActionButton.extended(
            elevation: 5,
            backgroundColor: themeColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              loc.addRecipe,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}
