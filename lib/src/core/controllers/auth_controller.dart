import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AuthController extends GetxController {
  // Text controllers for email and password
  final username = TextEditingController();
  final password = TextEditingController();

  // Observable states for password visibility and validation
  var showPassword = true.obs;
  var eightChars = false.obs;
  var hasNumber = false.obs;
  var hasSpecialCharacters = false.obs;
  var btnDisable = true.obs;
  var isLoading = false.obs;

  // Inisialisasi GoogleSignIn dengan clientId
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '252320645083-4vdp6k4180b0ggj1r1qu14c94olr9cos.apps.googleusercontent.com'
  );

  // Fungsi untuk login dengan Google
  Future<void> googleLogin() async {
    isLoading.value = true;
    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = authResult.user;
 
        if (user != null) {
          // Cek apakah data profil lengkap
          await checkUserProfileCompletion(user);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Google Sign-In Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Cek apakah data profil pengguna lengkap
  Future<void> checkUserProfileCompletion(User user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(user.uid);

      final docSnapshot = await userDoc.get();

      // Jika pengguna baru, tambahkan data dasar
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'firstName': '', // Tambahkan field wajib
          'lastName': '',
          'phoneNumber': '',
          'favorite': [],
        });
      }

      final userData = docSnapshot.data() ?? {};
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      final phoneNumber = userData['phoneNumber'] ?? '';

      // Periksa apakah data wajib kosong
      if (firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty) {
        Get.toNamed('/user/profile'); // Arahkan ke halaman untuk melengkapi profil
      } else {
        Get.toNamed('/home'); // Arahkan ke halaman utama
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to verify user profile. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveUserProfile(String firstName, String lastName, String phoneNumber) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(user.uid);

        // Perbarui data pengguna
        await userDoc.update({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        });

        Get.snackbar(
          'Profile Updated',
          'Your profile has been updated successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.toNamed('/home'); // Kembali ke halaman utama
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
    update(); // Update state for UI
  }

  // Clear text fields
  void clearFields() {
    username.clear();
    password.clear();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _setupPasswordListener();
  }

  @override
  void onClose() {
    // Dispose text controllers and listeners
    username.dispose();
    password.dispose();
    super.onClose();
  }

  // Setup listener to validate password
  void _setupPasswordListener() {
    password.addListener(() {
      final pwd = password.text;

      // Validate password rules
      eightChars.value = pwd.length >= 8;
      hasNumber.value = pwd.contains(RegExp(r'[0-9]'));
      hasSpecialCharacters.value =
          pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      // Enable or disable button based on password rules
      btnDisable.value = !(eightChars.value &&
              hasNumber.value &&
              hasSpecialCharacters.value) ||
          username.text.isEmpty;

      update(); // Update state for UI when conditions change
    });
  }

  // Check if email is valid
  bool isEmailValid() {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(username.text);
  }
}
