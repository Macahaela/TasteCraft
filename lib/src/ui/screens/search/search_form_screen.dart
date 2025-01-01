import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'package:recipe_app/src/core/models/helper_model.dart';
import 'dart:developer';

class SearchFormScreen extends StatelessWidget {
  const SearchFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxList<String> searchHistory = <String>[].obs;
    final RxList<RecipeModel> searchResults = <RecipeModel>[].obs;
    final TextEditingController searchController = TextEditingController();
    final RxString selectedSuggestion = ''.obs;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Obx(
        () => ListView(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: SearchWidget(
                      controller: searchController,
                      onSubmit: (value) async {
                        if (value.isNotEmpty) {
                          searchHistory.add(value);
                          final recipes = await _searchRecipes(value);
                          searchResults.assignAll(recipes);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            if (searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search History', style: TextTypography.mH2),
                    Wrap(
                      spacing: 8.0,
                      children: searchHistory.map((history) {
                        return GestureDetector(
                          onTap: () async {
                            final recipes = await _searchRecipes(history);
                            searchResults.assignAll(recipes);
                          },
                          child: Chip(
                            label: Text(history),
                            backgroundColor: AppColors.primary,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: const Text('Search Suggestions', style: TextTypography.mH2),
            ),
            FutureBuilder<List<String>>(
              future: _getSuggestionsFromFirebase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No suggestions available.'));
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Wrap(
                    spacing: 8.0,
                    children: snapshot.data!
                        .map(
                          (suggestion) => GestureDetector(
                            onTap: () async {
                              selectedSuggestion.value = suggestion;
                              final recipes = await _searchBySubstring(suggestion);
                              searchResults.assignAll(recipes);
                            },
                            child: Obx(
                              () => Chip(
                                label: Text(suggestion),
                                backgroundColor: selectedSuggestion.value == suggestion
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                labelStyle: TextStyle(
                                  color: selectedSuggestion.value == suggestion
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 20),
            if (searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Search Results', style: TextTypography.mH2),
                  ),
                  ...searchResults.map(
                    (recipe) => RecipeWidget(data: recipe),
                  ),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No recipes found.'),
                ),
              ),
          ],
        ),
      ),
    );
  }

    Future<List<RecipeModel>> _searchRecipes(String keyword) async {
    try {
      final recipes = await fetchRecipes();

      // Filter resep berdasarkan keyword
      return recipes
          .where((recipe) =>
              recipe.title.toLowerCase().contains(keyword.toLowerCase()) || // Jika substring cocok
              recipe.category.toLowerCase().contains(keyword.toLowerCase())) // Mencocokkan kategori
          .toList();
    } catch (e) {
      log('Error searching recipes: $e');
      return [];
    }
  }


  Future<List<RecipeModel>> _searchBySubstring(String keyword) async {
    try {
      final recipes = await fetchRecipes();
      return recipes
          .where((recipe) => recipe.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    } catch (e) {
      log('Error searching recipe by substring: $e');
      return [];
    }
  }

  Future<List<String>> _getSuggestionsFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Suggestions').get();
      return snapshot.docs.map((doc) {
        final name = doc['name'];
        return name is String ? name : '';
      }).toList();
    } catch (e) {
      log('Error fetching suggestions: $e');
      return [];
    }
  }

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Recipe_app').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RecipeModel(
          id: doc.id,
          author: data['author'] ?? '',
          title: data['title'] ?? '',
          category: data['category'] ?? '',
          duration: data['duration'] ?? '',
          favorite: false,
          imgAuthor: data['imgAuthor'] ?? '',
          imgCover: data['imgCover'] ?? '',
          steps: data['steps'] ?? [],
          ingredients: data['ingredients'] ?? [],
        );
      }).toList();
    } catch (e) {
      log('Error fetching recipes: $e');
      return [];
    }
  }
}

class RecipeWidget extends StatelessWidget {
  final RecipeModel data;

  const RecipeWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to Recipe Detail screen
          Get.toNamed(
            '/recipe/detail', // Make sure to have this route set up in GetX routing
            arguments: data.id, // Pass the recipe id as an argument
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  data.imgCover,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.category,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Duration: ${data.duration}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
