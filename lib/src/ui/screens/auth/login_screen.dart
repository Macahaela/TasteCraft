import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:recipe_app/src/core/controllers/auth_controller.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'dart:developer';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  // Fungsi login email dan password
  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Login dengan Firebase
      await auth.signInWithEmailAndPassword(email: email, password: password);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        saveUserToFirestore(user); // Simpan data pengguna ke Firestore
        Get.toNamed('/home'); // Arahkan ke halaman utama jika login berhasil
      }
    } catch (e) {
      // Handle login errors
      Get.snackbar(
        'Login Failed',
        'Invalid email or password!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // Fungsi login dengan Google
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = authResult.user;

        if (user != null) {
          await saveUserToFirestore(user); // Simpan data pengguna ke Firestore
          Get.toNamed('/home'); // Arahkan ke halaman utama jika berhasil
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

  Future<void> saveUserToFirestore(User user) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(user.uid);

      // Cek apakah data pengguna sudah ada di Firestore
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Jika belum ada, simpan data pengguna dengan field favorite
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoUrl': user.photoURL ?? '',
          'phoneNumber': '',
          'firstName': '',
          'lastName': '',
          'createdAt': FieldValue.serverTimestamp(),
          'favorite': [], // Field array untuk menyimpan resep favorit
        });
      } else {
        // Ambil data pengguna dan periksa apakah ada field kosong
        final userData = docSnapshot.data() as Map<String, dynamic>;

        if (userData['firstName'] == '' || userData['lastName'] == '' || userData['phoneNumber'] == '') {
          Get.toNamed('/profile'); // Arahkan ke halaman profil jika ada data kosong
        }

        // Pastikan field 'favorite' ada dan merupakan array
        if (!userData.containsKey('favorite') || userData['favorite'] is! List) {
          await userDoc.update({
            'favorite': [], // Tambahkan field favorite jika belum ada
          });
        }
      }
    } catch (e) {
      log('Error saving user to Firestore: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Welcome Title
                  titleGreeting(
                    title: 'Welcome Back!',
                    subtitle: 'Please enter your account here',
                  ),

                  // Username/Email TextField
                  textfieldIcon(
                    controller: authController.username,
                    hintText: 'Email or phone number',
                    icon: SvgPicture.asset(AssetIcons.message),
                    isRequired: 'Email or phone number is required!',
                  ),

                  // Password TextField
                  Obx(
                    () => textfieldPassword(
                      controller: authController.password,
                      obsecure: authController.showPassword.value,
                      hintText: 'Password',
                      isRequired: 'Password is required!',
                      icon: SvgPicture.asset(AssetIcons.lock),
                      onTap: () => authController.togglePasswordVisibility(),
                    ),
                  ),

                  // Forgot Password Link
                  InkWell(
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.mainText,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    onTap: () => Get.toNamed('/auth/password/recovery'),
                  ),

                  // Login Button
                  Container(
                    margin: const EdgeInsets.only(top: 50, bottom: 24),
                    child: Obx(
                      () => Button(
                        disable: authController.btnDisable.value,
                        onPressed: authController.btnDisable.value
                            ? () {}
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser(
                                    authController.username.text,
                                    authController.password.text,
                                    context,
                                  );
                                }
                              },
                        txtButton: 'Login',
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Or Continue With Text
                  const Text('Or continue with', style: TextTypography.sP2),

                  // Google Sign-In Button
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 24),
                    child: ButtonIcon(
                      onPressed: authController
                          .googleLogin, // Panggil fungsi googleLogin dari AuthController
                      txtButton: 'Google',
                      color: AppColors.primary,
                      icon: const Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Sign-Up Link
                  richTextLink(
                    title: 'Don’t have any account?',
                    linkText: ' Sign up',
                    onTap: () {
                      Get.toNamed('/auth/register');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
