import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:recipe_app/src/core/functions/network_image.dart';
import 'package:recipe_app/src/core/models/recipe_model.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/core/controllers/recipe_controller.dart';

class RecipeWidget extends StatelessWidget {
  final RecipeModel data;
  final recipeController = Get.find<RecipeController>();

  RecipeWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 31,
              width: 31,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: PNetworkImage(
                  data.imgAuthor,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                data.author,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mainText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 151,
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.toNamed(
                  '/recipe/detail',
                  arguments: data.id,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PNetworkImage(
                    data.imgCover,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10.0,
                top: 10.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        icon: Icon(
                          recipeController.isFavorite(data.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipeController.isFavorite(data.id)
                              ? Colors.redAccent
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => recipeController.toggleFavorite(data),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data.title.length > 14 // Batas maksimal 30 karakter
                ? '${data.title.substring(0, 14)}...' // Tambahkan ellipsis jika terlalu panjang
                 : data.title,
                style: TextTypography.mH2,
              ),
            ),
          ),
          onTap: () => Get.toNamed(
            '/recipe/detail',
            arguments: data.id,
          ),
        ),
        Row(
          children: [
            Text(
              data.category,
              style: TextTypography.category,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: const Icon(
                Octicons.primitive_dot,
                color: AppColors.secondaryText,
                size: 10,
              ),
            ),
            Text(
              data.duration,
              style: TextTypography.category,
            ),
          ],
        ),
      ],
    );
  }
}

class UserRecipe extends StatelessWidget {
  final RecipeModel data;

  const UserRecipe({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 151,
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.toNamed(
                  '/recipe/detail',
                  arguments: data.id,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PNetworkImage(
                    data.imgCover,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10.0,
                top: 10.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        onPressed: () {
                          // Logika untuk menambah atau menghapus favorit
                        },
                        icon: Icon(
                          data.favorite == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: data.favorite == true
                              ? Colors.redAccent
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data.title,
                style: TextTypography.mH2,
              ),
            ),
          ),
          onTap: () => Get.toNamed(
            '/recipe/detail',
            arguments: data.id,
          ),
        ),
        Row(
          children: [
            Text(
              data.category,
              style: TextTypography.category,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: const Icon(
                Octicons.primitive_dot,
                color: AppColors.secondaryText,
                size: 10,
              ),
            ),
            Text(
              data.duration,
              style: TextTypography.category,
            ),
          ],
        ),
      ],
    );
  }
}
