// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> dummyRecipes = [
    {'title': 'Spaghetti Bolognese', 'cuisine': 'Western', 'diet': 'High-Protein'},
    {'title': '蔬菜炒麵', 'cuisine': '中式', 'diet': '素食'},
    {'title': '壽司卷', 'cuisine': '日式', 'diet': '低醣'},
  ];

  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final filtered = dummyRecipes.where((recipe) {
      final title = recipe['title']!.toLowerCase();
      return title.contains(searchTerm.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyRecipe'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final recipe = filtered[index];
          return ListTile(
            leading: const Icon(Icons.fastfood),
            title: Text(recipe['title']!),
            subtitle: Text('${recipe['cuisine']} • ${recipe['diet']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // not yet connect, Phase 4 add
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Recipe tapped!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}