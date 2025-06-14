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

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;
  const HomeScreen({super.key, required this.onLocaleChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recipeBox = Hive.box<Recipe>('recipes');
  String searchTerm = '';
  User? _user;
  bool _isBackingUp = false;

  // 
  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _showOnboardingIfFirstLaunch();
    _autoRestoreFromCloud();
  }

  // First Time
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeColor = const Color(0xFFB17250);
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        final themeGradient = LinearGradient(
          colors: dark
              ? [Colors.black87, Colors.grey.shade900]
              : [themeColor, Colors.brown.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: themeGradient,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            // Drawer support About & chenage theme
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: themeColor),
                    child: Center(
                      child: Text("EasyRecipe",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text(loc.about),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => AboutPage(
                            isDark: isDarkMode.value,
                            onToggleTheme: () => setState(() => isDarkMode.value = !isDarkMode.value),
                          ),
                        ),
                      );
                    },
                  ),
                  // 這add more setting here
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // use Row 同show Logo and title let Drawer show
              title: Row(
                children: [
                  Image.asset(
                    Localizations.localeOf(context).languageCode == 'zh'
                        ? 'assets/logo_zh.png'
                        : 'assets/logo_en.png',
                    fit: BoxFit.contain,
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loc.appTitle,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: Colors.white),
                  ),
                ],
              ),
              actions: [
                if (_user == null)
                  IconButton(
                    icon: const Icon(Icons.login),
                    tooltip: 'Google 登入',
                    onPressed: _signInWithGoogle,
                  )
                else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _user!.photoURL != null && _user!.photoURL!.isNotEmpty
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
                      const SizedBox(width: 10),
                      if ((_user!.displayName ?? '').isNotEmpty)
                        Text(
                          _user!.displayName!,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        tooltip: '登出',
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                ],
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
                      hintStyle: GoogleFonts.nunito(color: Colors.teal.shade800),
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    ),
                    style: GoogleFonts.nunito(fontSize: 16),
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
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
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
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                (recipe.imagePath != null &&
                                        recipe.imagePath!.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(recipe.imagePath!),
                                          width: 74,
                                          height: 74,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.image_outlined,
                                            color: Colors.teal, size: 36),
                                      ),
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
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
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
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 8, top: 2),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors:
                                                    recipe.difficulty == 'easy'
                                                        ? [
                                                            Colors.green.shade200,
                                                            Colors.green.shade400
                                                          ]
                                                        : recipe.difficulty ==
                                                                'medium'
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
                                              borderRadius: BorderRadius.circular(8),
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
                                          padding: const EdgeInsets.only(top: 3.0),
                                          child: Text(
                                            '📋 ${recipe.ingredients}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
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
      },
    );
  }
}

// ------ Drawer setting/About page --------
class AboutPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onToggleTheme;
  const AboutPage({Key? key, this.isDark = false, this.onToggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.about),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("EasyRecipe", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            Text("${loc.author}: Issac Cheng"),
            Text("${loc.version}: 1.0.0"),
            const SizedBox(height: 10),
            Text(loc.aboutDesc),
            const SizedBox(height: 20),
            if (onToggleTheme != null)
              Row(
                children: [
                  Text(loc.theme),
                  Switch(
                    value: isDark,
                    onChanged: (_) => onToggleTheme?.call(),
                  ),
                  Text(isDark ? loc.dark : loc.light),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
