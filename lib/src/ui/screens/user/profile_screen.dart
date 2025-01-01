import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = true;
  bool isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            firstNameController.text = userDoc['firstName'] ?? '';
            lastNameController.text = userDoc['lastName'] ?? '';
            phoneNumberController.text = userDoc['phoneNumber'] ?? '';

            // Cek apakah profil lengkap
            isProfileComplete = firstNameController.text.isNotEmpty &&
                lastNameController.text.isNotEmpty &&
                phoneNumberController.text.isNotEmpty;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch profile data. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveProfileData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(user.uid);

        await userDoc.update({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'phoneNumber': phoneNumberController.text.trim(),
        });

        setState(() {
          isProfileComplete = true;
        });

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: AppColors.secondaryText,
        automaticallyImplyLeading: false, // Menonaktifkan tombol back otomatis
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isProfileComplete
              ? buildProfileView()
              : buildInitialForm(),
    );
  }

  Widget buildInitialForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Halo! Silakan lengkapi data profil Anda untuk melanjutkan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            textfieldIcon(
              controller: firstNameController,
              hintText: 'Nama depan',
              icon: const Icon(Icons.person, color: AppColors.secondary),
              isRequired: 'Nama depan harus diisi!',
            ),
            const SizedBox(height: 16),
            textfieldIcon(
              controller: lastNameController,
              hintText: 'Nama belakang',
              icon: const Icon(Icons.person, color: AppColors.secondary),
              isRequired: 'Nama belakang harus diisi!',
            ),
            const SizedBox(height: 16),
            textfieldIcon(
              controller: phoneNumberController,
              hintText: 'Nomor ponsel',
              icon: const Icon(Icons.phone, color: AppColors.secondary),
              isRequired: 'Nomor ponsel harus diisi!',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Button(
              onPressed: () {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty ||
                    phoneNumberController.text.isEmpty) {
                  Get.snackbar(
                    'Incomplete Data',
                    'Semua data wajib diisi.',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                } else {
                  saveProfileData(context);
                  Get.toNamed('/home');
                }
              },
              txtButton: 'Simpan Data',
              color: AppColors.primary,
              
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileView() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Email not available';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/avatar.png'), // Ganti dengan gambar profil
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProfileItem('Nama Depan', firstNameController.text),
                    const SizedBox(height: 8),
                    buildProfileItem('Nama Belakang', lastNameController.text),
                    const SizedBox(height: 8),
                    buildProfileItem(
                        'Nomor Ponsel', phoneNumberController.text),
                    const SizedBox(height: 8),
                    buildProfileItem(
                        'Email', email), // Menambahkan email di profil
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Button(
              onPressed: () {
                setState(() {
                  isProfileComplete = false;
                });
              },
              txtButton: 'Edit Profil',
              color: AppColors.mainText,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Modified textfieldIcon widget to handle empty fields
  Widget textfieldIcon({
    required TextEditingController controller,
    required String hintText,
    required Icon icon,
    required String isRequired,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: controller.text.isEmpty
                ? Colors.red
                : AppColors.secondary, // Warna merah jika kosong
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: controller.text.isEmpty ? Colors.red : AppColors.primary,
          ),
        ),
        errorText: controller.text.isEmpty
            ? isRequired
            : null, // Menampilkan error jika kosong
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}
