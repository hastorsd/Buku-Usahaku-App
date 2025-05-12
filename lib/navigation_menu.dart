import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thesis_app/screens/info/info_page.dart';
import 'package:thesis_app/screens/pesanan/pesanan_page.dart';
import 'package:thesis_app/screens/produk/produk_page.dart';
import 'package:thesis_app/screens/recap/recap_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(() {
        final currentIndex = controller.selectedIndex.value;
        final navItemCount = 4;
        final itemWidth = MediaQuery.of(context).size.width / navItemCount;

        return Stack(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentIndex,
                    onTap: (index) => controller.selectedIndex.value = index,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: const Color(0xFF007AFF),
                    unselectedItemColor: Colors.black,
                    showUnselectedLabels: true,
                    backgroundColor: Colors.white,
                    items: [
                      _buildNavItem(Icons.shopping_bag, "Produk"),
                      _buildNavItem(Icons.receipt_long, "Pesanan"),
                      _buildNavItem(Icons.attach_money, "Rekap"),
                      _buildNavItem(Icons.notes, "Catatan"),
                    ],
                  ),
                ),
              ),
            ),
            // ✅ Garis aktif animasi
            Positioned(
              width: MediaQuery.of(context).size.width,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment(
                    (currentIndex * 2 / (navItemCount - 1)) - 1,
                    0), // dari -1 ke 1
                child: Container(
                  width: itemWidth * 0.5,
                  height: 3,
                  margin: EdgeInsets.symmetric(horizontal: itemWidth * 0.25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const ProdukPage(),
    PesananPage(),
    const RecapPage(),
    const InfoPage(),
  ];
}
