import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/src/core/controllers/recipe_controller.dart';
import 'package:recipe_app/src/ui/widgets/recipe_widget.dart'; 
import 'package:recipe_app/src/ui/utils/helper_util.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeController = Get.find<RecipeController>();

    return Scaffold(
      backgroundColor:AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        backgroundColor: AppColors.bgColor,
      ),
      body: Obx(() {
        if (recipeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (recipeController.favoriteRecipes.isEmpty) {
          return const Center(
            child: Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 260,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: recipeController.favoriteRecipes.length,
          itemBuilder: (context, index) {
            return RecipeWidget(
              data: recipeController.favoriteRecipes[index],
            ); 
          },
        );
      }),
    );
  }
}
