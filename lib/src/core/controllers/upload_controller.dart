import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadController extends GetxController {
  // Controller untuk nama makanan dan deskripsi
  TextEditingController foodName = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController authorName = TextEditingController();

  // File dan nama gambar untuk cover dan author
  Rx<XFile?> coverImage = Rx<XFile?>(null);
  Rx<XFile?> authorImage = Rx<XFile?>(null);
  RxString coverImageName = ''.obs;
  RxString authorImageName = ''.obs;

  // Kategori dan durasi
  RxString selectedCategory = ''.obs;
  RxInt selectedDuration = 10.obs; // Durasi default

  // Daftar controller dinamis untuk bahan dan langkah
  var ingredients = <TextEditingController>[].obs;
  var steps = <TextEditingController>[].obs;

  UploadController() {
    addIngredient(); // Tambahkan input bahan awal
    addStep(); // Tambahkan langkah awal
  }

  // Tambahkan controller baru untuk bahan
  void addIngredient() {
    ingredients.add(TextEditingController());
  }

  // Tambahkan controller baru untuk langkah
  void addStep() {
    steps.add(TextEditingController());
  }

  // Hapus controller untuk bahan
  void removeIngredient(int index) {
    if (index < ingredients.length) {
      ingredients[index].dispose();
      ingredients.removeAt(index);
    }
  }

  // Hapus controller untuk langkah
  void removeStep(int index) {
    if (index < steps.length) {
      steps[index].dispose();
      steps.removeAt(index);
    }
  }

  // Dispose semua controller saat tidak digunakan lagi
  @override
  void onClose() {
    foodName.dispose();
    description.dispose();
    authorName.dispose();
    for (var controller in ingredients) {
      controller.dispose();
    }
    for (var controller in steps) {
      controller.dispose();
    }
    super.onClose();
  }
}
