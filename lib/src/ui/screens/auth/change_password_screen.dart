import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/widgets/helper_widget.dart';

class ChangePasswordScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _showPassword = false.obs;
  final RxBool _btnDisable = true.obs;

  ChangePasswordScreen({super.key});

  // Firebase Function to Change Password
  Future<void> _changePassword(BuildContext context) async {
    try {
      // Get the currently signed-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(_passwordController.text);
        await FirebaseAuth.instance
            .signOut(); // Log out the user after password change

        dialog(
          title: 'Password Changed',
          subtitle:
              'Your password has been successfully updated. Please log in again.',
          icon: Image.asset(AssetImages.emoticonParty),
          txtButton: 'Back to Login',
          onPressed: () {
            Get.offAllNamed('/auth/login');
          },
        );
      } else {
        Get.snackbar(
          'Error',
          'No user is signed in.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update password. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enable/Disable button based on input validation
    _passwordController.addListener(() {
      final password = _passwordController.text;
      final validPassword = password.length >= 8 &&
          password.contains(RegExp(r'\d')) && // Contains a number
          password
              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // Special character

      _btnDisable.value = !validPassword;
    });

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
                    title: 'Reset your password',
                    subtitle: 'Please enter your new password',
                  ),

                  // Password Field
                  Obx(
                    () => textfieldPassword(
                      controller: _passwordController,
                      obsecure: _showPassword.value,
                      hintText: 'Password',
                      icon: SvgPicture.asset(AssetIcons.lock),
                      onTap: () => _showPassword.toggle(),
                    ),
                  ),

                  // Password Requirements
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Your Password must contain:',
                      style: TextTypography.mP2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Column(
                      children: [
                        itemContain(
                          label: 'At least 8 characters',
                          isOk: _passwordController.text.length >= 8,
                        ),
                        const SizedBox(height: 15),
                        itemContain(
                          label: 'Contains a number',
                          isOk:
                              _passwordController.text.contains(RegExp(r'\d')),
                        ),
                        const SizedBox(height: 15),
                        itemContain(
                          label: 'Contains a special character',
                          isOk: _passwordController.text
                              .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
                        ),
                      ],
                    ),
                  ),

                  // Change Password Button
                  Container(
                    margin: const EdgeInsets.only(top: 50, bottom: 24),
                    child: Obx(
                      () => Button(
                        onPressed: _btnDisable.value
                            ? () {}
                            : () => _changePassword(context),
                        txtButton: 'Change',
                        color: AppColors.primary,
                        disable: _btnDisable.value,
                      ),
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
