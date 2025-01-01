import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/src/core/models/recipe_model.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';

class UserRecipeScreen extends StatelessWidget {
  const UserRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream to get data from Firestore collection
    Stream<List<RecipeModel>> fetchRecipes() {
      return FirebaseFirestore.instance
          .collection('Recipe_app')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RecipeModel.fromFirestore(doc))
              .toList());
    }

    return StreamBuilder<List<RecipeModel>>(
      stream: fetchRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No recipes available'),
          );
        }

        final recipes = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 220,
            childAspectRatio: 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 30,
          ),
          itemCount: recipes.length,
          itemBuilder: (BuildContext ctx, index) {
            return UserRecipe(data: recipes[index]);
          },
        );
      },
    );
  }
}
