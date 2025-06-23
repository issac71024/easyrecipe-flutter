import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'recipe_form.dart';
import '../l10n/app_localizations.dart';
import 'recipe_detail_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';

// ========== 天氣/金句卡片元件 ==========
class WeatherCard extends StatefulWidget {
  final bool isZh;
  const WeatherCard({super.key, required this.isZh});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String? weather;
  String? icon;
  double? temp;
  int? code;
  String? quote;
  String? suggestion;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void didUpdateWidget(covariant WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isZh != oldWidget.isZh) {
      _fetchAll();
    }
  }

  void _fetchAll() {
    fetchWeather();
    fetchQuote();
  }

  Future<void> fetchWeather() async {
    final lat = 22.3193; // 香港
    final lon = 114.1694;
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m';
    try {
      final res = await http.get(Uri.parse(url));
      final data = json.decode(res.body);
      if (data["current_weather"] != null) {
        final w = data["current_weather"];
        final _temp = w["temperature"]?.toDouble();
        final _code = w["weathercode"];
        setState(() {
          temp = _temp;
          code = _code;
          icon = weatherIcon(code ?? 0);
          weather = weatherDesc(code ?? 0, widget.isZh);
          suggestion = weatherSuggestion(_temp, _code, widget.isZh);
        });
      }
    } catch (e) {
      setState(() {
        suggestion = widget.isZh ? "無法取得天氣建議" : "Unable to fetch weather suggestion";
      });
    }
  }

  Future<void> fetchQuote() async {
    try {
      final lang = widget.isZh ? 'zh' : 'en';
      // quotable.io 不支援中文，這裡簡單用固定句子
      if (lang == 'en') {
        final res = await http.get(Uri.parse('https://api.quotable.io/random?lang=en'));
        final data = json.decode(res.body);
        setState(() {
          quote = data["content"];
        });
      } else {
        setState(() {
          quote = "美好的一天從一頓好料理開始。";
        });
      }
    } catch (e) {
      setState(() {
        quote = widget.isZh
            ? "美好的一天從一頓好料理開始。"
            : "A good day starts with good food!";
      });
    }
  }

  String weatherIcon(int code) {
    if ([0].contains(code)) return '☀️';
    if ([1, 2].contains(code)) return '⛅';
    if ([3].contains(code)) return '☁️';
    if ([45, 48].contains(code)) return '🌫️';
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return '🌧️';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return '❄️';
    if ([95, 96, 99].contains(code)) return '⛈️';
    return '🌦️';
  }

  String weatherDesc(int code, bool zh) {
    if ([0].contains(code)) return zh ? '晴朗' : 'Clear';
    if ([1, 2].contains(code)) return zh ? '間晴' : 'Partly Cloudy';
    if ([3].contains(code)) return zh ? '多雲' : 'Cloudy';
    if ([45, 48].contains(code)) return zh ? '霧' : 'Foggy';
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return zh ? '有雨' : 'Rainy';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return zh ? '下雪' : 'Snowy';
    if ([95, 96, 99].contains(code)) return zh ? '雷暴' : 'Thunderstorm';
    return zh ? '未知' : 'Unknown';
  }

  // 只給出天氣料理建議（不指定菜式）
  String weatherSuggestion(double? temp, int? code, bool zh) {
    if (temp == null || code == null) return zh ? "建議載入中..." : "Loading...";
    // 香港氣候習慣：29°C以上較熱, 18°C以下較冷
    if (temp >= 29) {
      return zh ? "建議清爽料理，例如沙拉、冷麵或輕食。" : "Suggestion: Refreshing dishes like salads, cold noodles, or light meals.";
    } else if (temp <= 18) {
      return zh ? "建議熱湯、燉菜或煲仔飯等溫暖料理。" : "Suggestion: Hot soup, stew, or warm comfort food.";
    } else if ([61, 63, 65, 80, 81, 82, 95, 96, 99].contains(code)) {
      return zh ? "有雨，建議來一份熱騰騰的家常料理。" : "Rainy day! Try some hearty home-cooked food.";
    }
    return zh ? "適合炒菜、便當、壽司等簡單家常料理。" : "Great for quick stir-fries, bento, sushi or simple home cooking.";
  }

@override
Widget build(BuildContext context) {
  final zh = widget.isZh;
  return Card(
    margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon ?? '🌦️', style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zh ? "香港天氣" : "Hong Kong Weather",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          weather ?? (zh ? "讀取中" : "Loading..."),
                          style: const TextStyle(fontSize: 17),
                        ),
                        if (temp != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              '${temp!.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.teal),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Cooking suggestion: 標題與內容分行
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.restaurant, color: Colors.teal, size: 21),
              const SizedBox(width: 7),
              Text(
                zh ? "料理建議：" : "Cooking Suggestion:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            suggestion ?? (zh ? "建議載入中..." : "Loading..."),
            style: TextStyle(color: Colors.teal[800], fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.amber, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  quote ??
                      (zh
                          ? "美好的一天從一頓好料理開始。"
                          : "A good day starts with good food!"),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
// =================== HomeScreen 主體 ===================
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
        // ... 你的 sample 10 個食譜 ...
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
        // ... 其餘略 ...
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
        body: ValueListenableBuilder(
          valueListenable: recipeBox.listenable(),
          builder: (context, Box<Recipe> box, _) {
            _autoBackupToCloud();

            final isZh = Localizations.localeOf(context).languageCode == 'zh';
            final recipes = box.values.toList();
            final searchLower = searchTerm.toLowerCase();
            final filtered = recipes.where((recipe) {
              if (isZh && recipe.titleZh.trim().isEmpty) return false;
              if (!isZh && recipe.titleEn.trim().isEmpty) return false;
              final title = isZh ? recipe.titleZh : recipe.titleEn;
              return title.toLowerCase().contains(searchLower) ||
                  recipe.ingredients.toLowerCase().contains(searchLower) ||
                  recipe.cookingTime.toString().contains(searchLower);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  WeatherCard(isZh: isZh), // 天氣卡片
                  if (filtered.isEmpty)
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
                    )
                  else
                    ...filtered.map((recipe) => Card(
                          elevation: 7,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 6),
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
                                            isZh
                                                ? recipe.titleZh
                                                : recipe.titleEn,
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
                                                margin: const EdgeInsets.only(
                                                    right: 8, top: 2),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: recipe.difficulty == 'easy'
                                                        ? [
                                                            Colors.green.shade200,
                                                            Colors.green.shade400
                                                          ]
                                                        : recipe.difficulty == 'medium'
                                                            ? [
                                                                Colors
                                                                    .orange.shade200,
                                                                Colors.orange
                                                              ]
                                                            : [
                                                                Colors.red.shade200,
                                                                Colors.red
                                                              ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _translateDifficulty(
                                                      recipe.difficulty, loc),
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Icon(Icons.schedule,
                                                  size: 15,
                                                  color: Colors.grey.shade500),
                                              Text(
                                                ' ${recipe.cookingTime} ${loc.minutes}',
                                                style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                          if (recipe.ingredients.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                '📋 ${recipe.ingredients}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () async {
                                        final confirm =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(loc.deleteDialogTitle),
                                            content:
                                                Text(loc.deleteDialogContent),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child:
                                                    Text(loc.deleteCancel),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                child:
                                                    Text(loc.deleteConfirm),
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
                        )),
                ],
              ),
            );
          },
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
