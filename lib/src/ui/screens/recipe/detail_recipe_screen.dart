import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/src/core/functions/network_image.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/component_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailRecipeScreen extends StatelessWidget {
  const DetailRecipeScreen({super.key});

  // Fetch the recipe details from Firestore
  Future<Map<String, dynamic>> fetchRecipe(String documentId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Recipe_app')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()!;
      } else {
        throw Exception('Document not found');
      }
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the documentId from Get.arguments (ensure it is a String)
    final String documentId = Get.arguments as String;
    

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecipe(documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Recipe not found'));
          }

          final data = snapshot.data!;
          final List<dynamic> ingredients = data['ingredients'] ?? [];
          final List<dynamic> steps = data['steps'] ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.5,
                elevation: 0,
                snap: true,
                floating: true,
                stretch: true,
                backgroundColor: Colors.grey.shade50,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                  ],
                  background: PNetworkImage(
                    data['imgCover'] ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(45),
                  child: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Container(
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'] ?? 'No Title', style: TextTypography.mH2),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(data['category'] ?? 'Unknown', style: TextTypography.category),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.grey,
                                  size: 10,
                                ),
                              ),
                              Text(data['duration'] ?? '0 min', style: TextTypography.category),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(data['imgAuthor'] ?? ''),
                                radius: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(data['author'] ?? 'Unknown', style: TextTypography.mH3),
                            ],
                          ),
                          const Divider(thickness: 1, height: 40),
                          const Text('Description', style: TextTypography.mH3),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(data['description'] ?? 'No description available',
                                style: TextTypography.sP2),
                          ),
                          const Divider(thickness: 1),
                          const Text('Ingredients', style: TextTypography.mH3),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ingredients.length,
                            itemBuilder: (context, index) {
                              return listItem(label: ingredients[index]);
                            },
                          ),
                          const Divider(thickness: 1),
                          const Text('Steps', style: TextTypography.mH3),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: steps.length,
                            itemBuilder: (context, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  stepNumber(number: index + 1),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(steps[index] ?? 'No step description',
                                        style: TextTypography.mP2),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
