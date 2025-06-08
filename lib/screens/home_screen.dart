import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recipe.dart';
import 'recipe_form.dart';
import '../l10n/app_localizations.dart';
import 'recipe_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _autoRestoreFromCloud();
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
    final snapshot =
        await firestore.collection('users').doc(uid).collection('recipes').get();
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
    final userCollection =
        firestore.collection('users').doc(uid).collection('recipes');
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
    final snapshot =
        await firestore.collection('users').doc(uid).collection('recipes').get();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
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
                if (_user?.photoURL != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL!),
                    radius: 16,
                  )
                else
                  const CircleAvatar(child: Icon(Icons.account_circle)),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user!.displayName ?? '',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(_user!.email ?? '',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
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
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
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
          final searchLower = searchTerm.toLowerCase();
          final filtered = box.values.where((recipe) {
            final title = isZh ? recipe.titleZh : recipe.titleEn;
            return title.toLowerCase().contains(searchLower) ||
                recipe.ingredients.toLowerCase().contains(searchLower) ||
                recipe.cookingTime.toString().contains(searchLower);
          }).toList();

          if (filtered.isEmpty) {
            return Center(child: Text(loc.noRecipe));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final recipe = filtered[index];
              return ListTile(
                leading: (recipe.imagePath != null &&
                        recipe.imagePath!.isNotEmpty)
                    ? Image.file(
                        File(recipe.imagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported, size: 40),
                title: Text(isZh ? recipe.titleZh : recipe.titleEn),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${translateCuisine(loc)[recipe.cuisine] ?? recipe.cuisine} • '
                      '${translateDiet(loc)[recipe.diet] ?? recipe.diet}',
                    ),
                    Text(
                      '⏱️ ${recipe.cookingTime} ${loc.minutes} • '
                      '${loc.difficultyLabel}：${_translateDifficulty(recipe.difficulty, loc)}',
                    ),
                    if (recipe.ingredients.isNotEmpty)
                      Text('📋 材料：${recipe.ingredients}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc.deleteDialogTitle),
                        content: Text(loc.deleteDialogContent),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.deleteCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
