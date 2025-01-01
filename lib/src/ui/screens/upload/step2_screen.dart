import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/src/core/controllers/helper_controller.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';

class Step2Screen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UploadController step2C = Get.put(UploadController());

  Step2Screen({super.key});

  // Fungsi untuk memperbarui dokumen yang ada di Firestore
  Future<void> updateFirestoreDocument(String docId) async {
    try {
      // Data baru untuk ditambahkan ke dokumen
      final data = {
        'ingredients':
            step2C.ingredients.map((controller) => controller.text).toList(),
        'steps': step2C.steps.map((controller) => controller.text).toList(),
        'updatedAt': FieldValue.serverTimestamp(), // Tanggal pembaruan
      };

      // Perbarui dokumen berdasarkan docId
      await FirebaseFirestore.instance
          .collection('Recipe_app')
          .doc(docId)
          .update(data);

      // Tampilkan dialog sukses
      dialog(
        title: 'Upload Success',
        subtitle:
            'Your recipe has been uploaded, you can see it on your profile',
        icon: Image.asset(AssetImages.emoticonParty),
        txtButton: 'Back to Home',
        onPressed: () {
          Get.offAllNamed('/home'); // Navigasi ke halaman utama
        },
      );
    } catch (e) {
      // Tampilkan pesan error jika gagal
      Get.snackbar('Error', 'Failed to update recipe: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan document ID dari Step1Screen
    final String docId = Get.arguments as String;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 70),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: pagination(currentPage: '2', nextPage: '2'),
            ),
            Expanded(
              child: ListView(
                children: [
                  // Ingredients Section
                  Container(
                    margin: const EdgeInsets.only(left: 24, bottom: 10),
                    child: labelForm(label: 'Ingredients'),
                  ),
                  Obx(() => Column(
                        children: step2C.ingredients.map((controller) {
                          return ListTile(
                            minLeadingWidth: 10,
                            leading: SvgPicture.asset(AssetIcons.drag),
                            title: textfield(
                              controller: controller,
                              hintText: 'Enter Ingredient',
                              isRequired: 'Ingredient is required!',
                            ),
                          );
                        }).toList(),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 30),
                    child: ButtonOutline(
                      onPressed: step2C.addIngredient,
                      color: AppColors.outline,
                      colorLabel: AppColors.titleText,
                      txtButton: '+ Ingredient',
                    ),
                  ),
                  divider(),

                  // Steps Section
                  Container(
                    margin: const EdgeInsets.only(left: 24, bottom: 10),
                    child: labelForm(label: 'Steps'),
                  ),
                  Obx(() => Column(
                        children: step2C.steps.map((controller) {
                          return ListTile(
                            minLeadingWidth: 10,
                            leading: stepNumber(
                                number: step2C.steps.indexOf(controller) + 1),
                            title: textarea(
                              controller: controller,
                              hintText: 'Describe this step',
                              minLines: 4,
                            ),
                          );
                        }).toList(),
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 30),
                    child: ButtonOutline(
                      onPressed: step2C.addStep,
                      color: AppColors.outline,
                      colorLabel: AppColors.titleText,
                      txtButton: '+ Step',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Button(
                          disable: false,
                          width: SizeConfig().deviceWidth(context) / 2.5,
                          onPressed: () => updateFirestoreDocument(docId),
                          txtButton: 'Done',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
