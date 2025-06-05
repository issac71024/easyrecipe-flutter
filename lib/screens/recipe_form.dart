import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String cuisine = '中式';
  String diet = '無';
  File? imageFile;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Recipe>('recipes');
      final recipe = Recipe(
        title: title,
        cuisine: cuisine,
        diet: diet,
      );

      await box.add(recipe);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增食譜')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (imageFile != null) Image.file(imageFile!),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('選擇圖片'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '標題'),
                validator: (value) =>
                    value == null || value.isEmpty ? '請輸入標題' : null,
                onChanged: (value) => title = value,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '料理類型'),
                value: cuisine,
                items: ['中式', '日式', '西式']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => cuisine = value ?? '中式',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '飲食分類'),
                value: diet,
                items: ['無', '素食', '高蛋白', '低醣']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => diet = value ?? '無',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('儲存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}