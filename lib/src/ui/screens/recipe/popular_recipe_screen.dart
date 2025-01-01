import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/src/core/models/recipe_model.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'dart:developer' as developer;

class PopularRecipeScreen extends StatelessWidget {
  const PopularRecipeScreen({super.key});

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Recipe_app').get();

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
          steps: data['steps'] ?? '',
          ingredients: data['ingredients'] ?? '',
        );
      }).toList();
    } catch (e) {
      developer.log('Error fetching recipes: $e', name: 'PopularRecipeScreen');
      return []; // Return empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecipeModel>>(
      future: fetchRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recipes found'));
        }

        final recipes = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 260,
            childAspectRatio: 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 30,
          ),
          itemCount: recipes.length,
          itemBuilder: (BuildContext ctx, index) {
            return RecipeWidget(data: recipes[index]);
          },
        );
      },
    );
  }
}
