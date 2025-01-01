import 'package:get/get.dart';
import 'package:recipe_app/src/ui/screens/auth/change_password_screen.dart';
import 'package:recipe_app/src/ui/screens/auth/login_screen.dart';
import 'package:recipe_app/src/ui/screens/auth/password_recovery_screen.dart';
import 'package:recipe_app/src/ui/screens/auth/register_screen.dart';
import 'package:recipe_app/src/ui/screens/intro/onboarding_screen.dart';
import 'package:recipe_app/src/ui/screens/main/home_screen.dart';
import 'package:recipe_app/src/ui/screens/recipe/detail_recipe_screen.dart';
import 'package:recipe_app/src/ui/screens/search/search_form_screen.dart';
import 'package:recipe_app/src/ui/screens/upload/step1_screen.dart';
import 'package:recipe_app/src/ui/screens/upload/step2_screen.dart';
import 'package:recipe_app/src/ui/screens/user/profile_screen.dart';

class Routes {
  static final pages = [
    GetPage(
      name: '/intro/onboarding',
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: '/auth/login',
      page: () => LoginScreen(),
    ),
    GetPage(
      name: '/auth/register',
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: '/auth/password/recovery',
      page: () => PasswordRecoveryScreen(),
    ),
    GetPage(
      name: '/auth/password/change',
      page: () => ChangePasswordScreen(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: '/search/form',
      page: () => const SearchFormScreen(),
    ),
    GetPage(
      name: '/recipe/detail',
      page: () => const DetailRecipeScreen(),
    ),
    GetPage(
      name: '/upload/step/1',
      page: () => Step1Screen(),
    ),
    GetPage(
      name: '/upload/step/2',
      page: () => Step2Screen(),
    ),
    GetPage(
      name: '/user/profile',
      page: () => ProfileScreen(),
    ),
  ];
}
