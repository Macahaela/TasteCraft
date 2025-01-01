import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_app/src/ui/screens/favorite/favorite_screen.dart';
import 'package:recipe_app/src/ui/screens/user/profile_screen.dart';
import 'package:recipe_app/src/ui/utils/helper_util.dart';
import 'package:recipe_app/src/ui/screens/main/dashboard_screen.dart';
import 'package:recipe_app/src/ui/screens/upload/step1_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List pages
    List<Widget> pages = [
      const DashboardScreen(),
      Step1Screen(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];
    final navC = Get.put(NavbarController());
    return Obx(
      () => Scaffold(
        body: pages.elementAt(navC.index.value),
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0.5,
          shape: const CircularNotchedRectangle(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.white,
              child: BottomNavigationBar(
                selectedItemColor: AppColors.primary,
                selectedFontSize: 12,
                currentIndex: navC.index.value,
                onTap: (index) {
                  navC.setIndex(index);
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    label: "Home",
                    icon: SvgPicture.asset(
                      AssetIcons.home,
                      color: navC.index.value == 0
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: "Upload",
                    icon: SvgPicture.asset(
                      AssetIcons.edit,
                      color: navC.index.value == 1
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: "Favorite",
                    icon: SvgPicture.asset(
                      AssetIcons.favorite,
                      color: navC.index.value == 2
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: "Profile",
                    icon: SvgPicture.asset(
                      AssetIcons.profile,
                      color: navC.index.value == 3
                          ? AppColors.primary
                          : AppColors.secondaryText,
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

class NavbarController extends GetxController {
  var index = 0.obs;
  void setIndex(int page) => index.value = page;
}
