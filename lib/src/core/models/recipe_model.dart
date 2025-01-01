import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String author;
  final String title;
  final String category;
  final String duration;
  final String imgAuthor;
  final String imgCover;
  final bool favorite;
  final List<dynamic> ingredients;  // Assuming this is a list of dynamic type
  final List<dynamic> steps;        // Assuming this is a list of dynamic type


  RecipeModel({
    required this.id,
    required this.author,
    required this.title,
    required this.category,
    required this.duration,
    required this.imgAuthor,
    required this.imgCover,
    required this.favorite,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      imgAuthor: json['img_author']?.toString() ?? '',
      imgCover: json['img_cover']?.toString() ?? '',
      favorite: json['favorite'] is bool ? json['favorite'] : false,
      ingredients: json['ingredients'] ?? [], // Assuming it's a list
      steps: json['steps'] ?? [],             // Assuming it's a list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'category': category,
      'duration': duration,
      'img_author': imgAuthor,
      'img_cover': imgCover,
      'favorite': favorite,
      'steps' : steps,
      'ingredients' : ingredients,
    };
  }
  // Convert Firestore document to RecipeModel
  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    return RecipeModel(
      id: doc['id'],
      title: doc['title'],
      imgAuthor: doc['imgAuthor'],
      imgCover: doc['imgCover'],
      author: doc['author'],
      category: doc['category'],
      duration: doc['duration'],
      favorite: doc['favorite'],
      steps: doc['steps'],
      ingredients: doc['ingredients'],
    );
  }

  static List<RecipeModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => RecipeModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
