import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/src/core/models/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class RecipeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<RecipeModel> recipes = <RecipeModel>[].obs;
  final RxList<RecipeModel> favoriteRecipes = <RecipeModel>[].obs;
  final RxBool isLoading = false.obs;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
    fetchFavoriteRecipes();

    // Reset data saat user logout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        recipes.clear();
        favoriteRecipes.clear();
      } else {
        fetchRecipes();
        fetchFavoriteRecipes();
      }
    });
  }

  Future<void> fetchRecipes() async {
    try {
      isLoading.value = true;
      final QuerySnapshot recipesSnapshot =
          await _firestore.collection('Recipe_app').get();

      recipes.value = recipesSnapshot.docs
          .map((doc) => RecipeModel(
                id: doc.id,
                author: doc['author'] ?? '',
                title: doc['title'] ?? '',
                category: doc['category'] ?? '',
                duration: doc['duration'] ?? '',
                imgAuthor: doc['imgAuthor'] ?? '',
                imgCover: doc['imgCover'] ?? '',
                favorite: false,
                ingredients: doc['ingredients'] ?? [],
                steps: doc['steps'] ?? [],
              ))
          .toList();
    } catch (e) {
      log('Error fetching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFavoriteRecipes() async {
    try {
      favoriteRecipes.clear(); // Reset data favorit sebelum fetching
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final List<dynamic> favoriteIds = userDoc.data()?['favorite'] ?? [];

      if (favoriteIds.isNotEmpty) {
        final QuerySnapshot favoritesSnapshot = await _firestore
            .collection('Recipe_app')
            .where(FieldPath.documentId, whereIn: favoriteIds)
            .get();

        favoriteRecipes.value = favoritesSnapshot.docs
            .map((doc) => RecipeModel(
                  id: doc.id,
                  author: doc['author'] ?? '',
                  title: doc['title'] ?? '',
                  category: doc['category'] ?? '',
                  duration: doc['duration'] ?? '',
                  imgAuthor: doc['imgAuthor'] ?? '',
                  imgCover: doc['imgCover'] ?? '',
                  favorite: true,
                  ingredients: doc['ingredients'] ?? [],
                  steps: doc['steps'] ?? [],
                ))
            .toList();
      }
    } catch (e) {
      log('Error fetching favorite recipes: $e');
    }
  }

  Future<void> toggleFavorite(RecipeModel recipe) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final List<dynamic> favoriteIds = docSnapshot.data()?['favorite'] ?? [];

      if (favoriteIds.contains(recipe.id)) {
        // Hapus dari favorit
        favoriteIds.remove(recipe.id);
        await userDoc.update({'favorite': favoriteIds});
        Get.snackbar(
          'Removed from Favorites',
          '${recipe.title} has been removed from your favorites.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
        );
      } else {
        // Tambahkan ke favorit
        favoriteIds.add(recipe.id);
        await userDoc.update({'favorite': favoriteIds});
        Get.snackbar(
          'Added to Favorites',
          '${recipe.title} has been added to your favorites.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
        );
      }

      // Refresh daftar resep favorit setelah pembaruan
      fetchFavoriteRecipes();
    } catch (e) {
      log('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorite status. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
      );
    }
  }

  bool isFavorite(String recipeId) {
    return favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }
}
