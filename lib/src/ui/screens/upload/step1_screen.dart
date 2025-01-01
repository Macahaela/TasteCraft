import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:recipe_app/src/core/controllers/helper_controller.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'dart:developer';

class Step1Screen extends StatefulWidget {
  const Step1Screen({super.key});

  @override
  Step1ScreenState createState() => Step1ScreenState();
}

class Step1ScreenState extends State<Step1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final UploadController uploadController = Get.put(UploadController());
  
  XFile? _imageFile;
  String? _imageName;

  // Add variables for author image and name
  XFile? _authorImageFile;
  String? _authorImageName;
  TextEditingController authorController = TextEditingController();

  final CloudinaryService _cloudinaryService = CloudinaryService();
  late final UploadController step1C;

  // Variable to store selected duration
  final RxInt selectedDuration = 10.obs;
  // Variable to store selected category
  String? selectedCategory;

  // List to store categories fetched from Firestore
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    step1C = Get.put(UploadController());
    _fetchCategories(); // Fetch categories on init
  }

  // Fetch categories from Firestore collection 'App-Category'
  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('App-Category')
          .get();

      setState(() {
        categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      log('Error fetching categories: $e');
      Get.snackbar('Error', 'Failed to fetch categories!',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Function to pick an image for recipe cover
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = image;
          _imageName = image.name;
        });
      } else {
        log('No image selected');
        Get.snackbar('Warning', 'No image selected!',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      log('Error selecting image: $e');
      Get.snackbar('Error', 'Failed to pick an image!',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Function to pick an image for author
  Future<void> _pickAuthorImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _authorImageFile = image;
          _authorImageName = image.name;
        });
      } else {
        log('No author image selected');
        Get.snackbar('Warning', 'No image selected!',
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      log('Error selecting image: $e');
      Get.snackbar('Error', 'Failed to pick author image!',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Function to save data to Firestore
  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null || _authorImageFile == null) {
        log('No image selected');
        Get.snackbar('Warning', 'Please select an image for cover and author!',
            snackPosition: SnackPosition.TOP);
        return;
      }

      if (selectedCategory == null) {
        log('No category selected');
        Get.snackbar('Warning', 'Please select a category!',
            snackPosition: SnackPosition.TOP);
        return;
      }

      try {
        // Upload cover image to Cloudinary
        String? imageUrl = kIsWeb
            ? await _cloudinaryService.uploadImage(_imageFile)
            : await _cloudinaryService.uploadImage(File(_imageFile!.path));

        // Upload author image to Cloudinary
        String? authorImageUrl = kIsWeb
            ? await _cloudinaryService.uploadImage(_authorImageFile)
            : await _cloudinaryService.uploadImage(File(_authorImageFile!.path));

        if (imageUrl == null || authorImageUrl == null) {
          log('Failed to upload images');
          Get.snackbar('Error', 'Failed to upload images!',
              snackPosition: SnackPosition.TOP);
          return;
        }
        log('Image URL: $imageUrl');
        log('Author Image URL: $authorImageUrl');

        // Validate required fields
        if (step1C.foodName.text.trim().isEmpty ||
            step1C.description.text.trim().isEmpty ||
            authorController.text.trim().isEmpty) {
          Get.snackbar('Warning', 'All fields are required!',
              snackPosition: SnackPosition.TOP);
          return;
        }

        // Save data to Firestore
        Map<String, dynamic> data = {
          'title': step1C.foodName.text.trim(),
          'description': step1C.description.text.trim(),
          'imgCover': imageUrl,
          'imgAuthor': authorImageUrl, // Add author image URL
          'author': authorController.text.trim(), // Add author name
          'duration': formatDuration(selectedDuration.value).toString(), // Convert to string
          'category': selectedCategory, // Add selected category
          'timestamp': FieldValue.serverTimestamp(),
        };

        final docRef = await FirebaseFirestore.instance
            .collection('Recipe_app')
            .add(data);
        log('Data saved successfully');

         // Show notification and delay before navigating to step2_screen
        Get.snackbar(
          'Processing',
          'Please wait while we prepare the next step...',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3), // Notification duration
        );

        await Future.delayed(const Duration(seconds: 3)); // Wait for 5 seconds

        // Navigate to the next step with document ID
        Get.toNamed('/upload/step/2', arguments: docRef.id);
      } catch (e) {
        log('Error saving data: $e');
        Get.snackbar('Error', 'Failed to save data!',
            snackPosition: SnackPosition.TOP);
      }
    } else {
      log('Form validation failed');
      Get.snackbar('Warning', 'Please complete all required fields!',
          snackPosition: SnackPosition.TOP);
    }
  }

  // Build a slider for selecting duration
  Widget buildSlider() {
    return Obx(() {
      return Slider(
        value: selectedDuration.value.toDouble(),
        min: 10,
        max: 60,
        divisions: 5, // Divide the range into equal steps
        label: formatDuration(selectedDuration.value),
        onChanged: (value) {
          selectedDuration.value = value.round();
        },
      );
    });
  }

  // Helper function to format the duration value
  String formatDuration(int duration) {
    if (duration == 10) {
      return '<10 mins';
    } else if (duration == 60) {
      return '>60 mins';
    } else {
      return '$duration mins';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),
              pagination(currentPage: '1', nextPage: '2'),
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        // Image upload section for recipe cover
                        Container(
                          margin: const EdgeInsets.only(top: 35),
                          width: SizeConfig().deviceWidth(context) / 1.2,
                          height: SizeConfig().deviceHeight(context) / 5,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            strokeWidth: 2,
                            padding: const EdgeInsets.all(6),
                            dashPattern: const [5, 5, 5, 5],
                            color: const Color(0xFFD0DBEA),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: Center(
                                child: InkWell(
                                  onTap: _pickImage,
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.blue.withAlpha(30),
                                  child: uploadIcon(
                                    title: 'Add Cover Photo',
                                    subtitle: '(Up to 2 Mb)',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_imageFile != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              _imageName ?? 'No image selected',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        // Image upload section for author image
                        Container(
                          margin: const EdgeInsets.only(top: 35),
                          width: SizeConfig().deviceWidth(context) / 1.2,
                          height: SizeConfig().deviceHeight(context) / 5,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            strokeWidth: 2,
                            padding: const EdgeInsets.all(6),
                            dashPattern: const [5, 5, 5, 5],
                            color: const Color(0xFFD0DBEA),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: Center(
                                child: InkWell(
                                  onTap: _pickAuthorImage,
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.blue.withAlpha(30),
                                  child: uploadIcon(
                                    title: 'Add Author Photo',
                                    subtitle: '(Up to 2 Mb)',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_authorImageFile != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              _authorImageName ?? 'No image selected',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Author name input
                    labelForm(label: 'Author Name'),
                    textfield(
                      controller: authorController,
                      hintText: 'Enter author name',
                      isRequired: 'Author name is required!',
                    ),

                    // Food name input
                    labelForm(label: 'Food Name'),
                    textfield(
                      controller: step1C.foodName,
                      hintText: 'Enter food name',
                      isRequired: 'Food name is required!',
                    ),

                    // Description input
                    labelForm(label: 'Description'),
                    textarea(
                      minLines: 3,
                      controller: step1C.description,
                      hintText: 'Tell a little about your food',
                      isRequired: 'Description is required!',
                    ),

                    // Duration slider
                    richLabel(
                        title1: 'Cooking Duration', title2: ' (in minutes)'),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('<10', style: TextTypography.p1Primary),
                        Text('30', style: TextTypography.p1Primary),
                        Text('>60', style: TextTypography.p1Primary),
                      ],
                    ),
                    buildSlider(),

                    // Category dropdown
                    labelForm(label: 'Select Category'),
                    DropdownButton<String>(
                      value: selectedCategory,
                      hint: Text('Choose category'),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),

                    // Submit button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 50),
                      child: Button(
                        disable: false,
                        onPressed: _saveData,
                        txtButton: 'Next',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
