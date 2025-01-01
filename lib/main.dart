import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'src/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Import FirebaseOptions yang dihasilkan
import 'package:recipe_app/src/core/controllers/recipe_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Inisialisasi Firebase menggunakan konfigurasi untuk platform yang tepat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Gunakan konfigurasi Firebase untuk platform saat ini
  );
  
  Get.put(RecipeController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
      defaultTransition: Transition.native,
      initialRoute: "/intro/onboarding",
      getPages: Routes.pages,
    );
  }
}
