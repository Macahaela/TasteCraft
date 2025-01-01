import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveImageToRealtimeDB(String imageUrl) async {
    try {
      await _firestore.collection('images').add({'imageUrl': imageUrl});
    } catch (e) {
      log('Firestore error: $e');
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    try {
      await _firestore.collection('Recipe_app').add(recipeData);
    } catch (e) {
      log('Firestore error: $e');
    }
  }

  Future<DocumentReference> getLastAddedRecipe() async {
    final querySnapshot = await _firestore.collection('Recipe_app').orderBy('timestamp', descending: true).limit(1).get();
    return querySnapshot.docs.first.reference;
  }

  Future<void> updateRecipe(DocumentReference recipeRef, Map<String, dynamic> data) async {
    try {
      await recipeRef.update(data);
    } catch (e) {
      log('Firestore update error: $e');
    }
  }
}
