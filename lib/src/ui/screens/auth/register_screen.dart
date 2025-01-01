import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';
import 'package:recipe_app/src/core/controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  // Function to register user and navigate to login screen
  Future<void> registerUser(
      String email, String password, BuildContext context) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Check if the email is already in use
      final signInMethods = await auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        Get.snackbar(
          'Error',
          'Email is already in use',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // If email is already in use, stop the execution
      }

      // Create user without sending email verification
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user object from the Firebase response
      User? user = userCredential.user;

      if (user != null) {
        // Show a Snackbar or Dialog here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registrasi berhasil!'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );

        // Clear fields in AuthController
        Get.find<AuthController>().clearFields();

        // Navigate to login screen
        Get.toNamed('/auth/login');
      }
    } catch (e) {
      // Handle errors (like network issues, wrong credentials, etc.)
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController()); // Use AuthController

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      titleGreeting(
                        title: 'Welcome!',
                        subtitle: 'Please enter your account here',
                      ),
                      // Email TextField
                      textfieldIcon(
                        controller: authController.username,
                        hintText: 'Email',
                        icon: SvgPicture.asset(AssetIcons.message),
                        isRequired: 'Email is required!',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required!';
                          }
                          // Email validation regex
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email!';
                          }
                          return null;
                        },
                      ),
                      // Password TextField
                      textfieldPassword(
                        controller: authController.password,
                        obsecure: authController.showPassword.value,
                        hintText: 'Password',
                        icon: SvgPicture.asset(AssetIcons.lock),
                        onTap: authController.togglePasswordVisibility,
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Your Password must contain:',
                          style: TextTypography.mP2,
                        ),
                      ),
                      // Password Validation Criteria
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            itemContain(
                              label: 'At least 8 characters',
                              isOk: authController.eightChars.value,
                            ),
                            const SizedBox(height: 15),
                            itemContain(
                              label: 'Contains a number',
                              isOk: authController.hasNumber.value,
                            ),
                            const SizedBox(height: 15),
                            itemContain(
                              label: 'Contains a special character',
                              isOk: authController.hasSpecialCharacters.value,
                            ),
                          ],
                        ),
                      ),
                      // Sign Up Button
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 24),
                        child: Button(
                          onPressed: authController.btnDisable.value
                              ? () {}
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await registerUser(
                                      authController.username.text,
                                      authController.password.text,
                                      context,
                                    );
                                  }
                                },
                          txtButton: 'Sign Up',
                          color: authController.btnDisable.value
                              ? AppColors.secondary
                              : AppColors.primary,
                          disable: authController.btnDisable.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
