import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/src/core/controllers/helper_controller.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'package:recipe_app/src/core/models/recipe_model.dart';
import 'package:recipe_app/src/core/controllers/recipe_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  String selectedCategory = 'All'; 
  final recipeController = Get.find<RecipeController>();

  Future<List<String>> fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('App-Category').get();
      List<String> categories = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      categories.insert(0, 'All'); // Tambahkan kategori "All" di awal
      return categories;
    } catch (e) {
      // Log error or handle it
      return ['All']; // Default fallback if there's an error
    }
  }

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Recipe_app');

      if (selectedCategory != 'All') {
        query = query.where('category', isEqualTo: selectedCategory);
      }

      final querySnapshot = await query.get();

      // Mengubah data dari Firestore menjadi list of RecipeModel
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return RecipeModel(
          id: doc.id,
          author: data['author'] ?? '',
          title: data['title'] ?? '',
          category: data['category'] ?? '',
          duration: data['duration'] ?? '',
          favorite: false, // Selalu set ke false
          imgAuthor: data['imgAuthor'] ?? '',
          imgCover: data['imgCover'] ?? '',
          steps: data['steps'] ?? [],
          ingredients: data['ingredients'] ?? [],
        );
      }).toList();
    } catch (e) {
      return []; // Return empty list if error occurs
    }
  }

  Widget buildFilter(List<String> choice) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: choice.length,
        itemBuilder: (context, index) {
          final category = choice[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category; // Perbarui kategori yang dipilih
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? AppColors.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: FutureBuilder<List<String>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          } else {
            List<String> choice = snapshot.data!;

            return Column(
              children: [
                const SizedBox(height: 70),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      searchForm(context: context, redirect: true),
                      Container(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: const Text('Category', style: TextTypography.mH2),
                      ),
                      buildFilter(choice),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: divider(),
                ),
                Expanded(
                  child: FutureBuilder<List<RecipeModel>>(
                    future: fetchRecipes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No recipes found for the selected category'));
                      } else {
                        final recipes = snapshot.data!;
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisExtent: 260,
                            childAspectRatio: 1,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 30,
                          ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            return RecipeWidget(data: recipes[index]);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
