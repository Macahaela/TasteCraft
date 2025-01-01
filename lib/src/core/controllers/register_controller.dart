import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  // Text controllers
  final username = TextEditingController();
  final password = TextEditingController();

  // Observable states
  var showPassword = true.obs;
  var eightChars = false.obs;
  var hasNumber = false.obs;
  var hasSpecialCharacters = false.obs;
  var btnDisable = true.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
    update(); // Update state for UI
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
      hasSpecialCharacters.value = pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      // Enable or disable button based on password rules
      btnDisable.value = !(eightChars.value && hasNumber.value && hasSpecialCharacters.value) || username.text.isEmpty;

      update(); // Update state for UI when conditions change
    });
  }

  // Check if email is valid (you can call this before submitting the form)
  bool isEmailValid() {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(username.text);
  }
}
