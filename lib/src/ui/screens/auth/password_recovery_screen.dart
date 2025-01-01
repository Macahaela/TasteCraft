import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';

class PasswordRecoveryScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  PasswordRecoveryScreen({super.key});

  // Firebase function to send password reset email
  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      // Sending password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );

      // Show dialog after successful email sent
      dialog(
        title: 'Email Sent',
        subtitle:
            'A password recovery email has been sent to ${_emailController.text}. Please check your inbox. After resetting your password, please refresh the app before logging in.',
        icon: const Icon(Icons.email, size: 48, color: AppColors.primary),
        txtButton: 'Back to Login',
        onPressed: () {
          Get.offAllNamed('/auth/login');
        },
      );
    } catch (e) {
      String errorMessage = 'Failed to send password recovery email.';

      // Checking if error is specific to invalid email
      if (e is FirebaseAuthException && e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      }

      // Display an error message
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Title and Subtitle
                  titleGreeting(
                    title: 'Password recovery',
                    subtitle: 'Enter your email to recover your password',
                  ),

                  // Email Input Field
                  textfieldIcon(
                    controller: _emailController,
                    hintText: 'Email address',
                    icon: SvgPicture.asset(AssetIcons.message),
                    isRequired: 'Email is required!',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required!';
                      }

                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email!';
                      }

                      return null;
                    },
                  ),

                  // Recovery Button
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Button(
                      disable: false,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendPasswordResetEmail(context);
                        }
                      },
                      txtButton: 'Recover Password',
                      color: AppColors.primary,
                    ),
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
