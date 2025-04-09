import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:thesis_app/screens/info_page.dart';
import 'package:thesis_app/screens/pesanan_page.dart';
import 'package:thesis_app/screens/produk/produk_page.dart';
import 'package:thesis_app/screens/recap_page.dart';
import 'dart:ui';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(() => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  border: const Border(
                    top: BorderSide(color: Colors.black12),
                  ),
                ),
                child: SalomonBottomBar(
                  backgroundColor: Colors.transparent,
                  currentIndex: controller.selectedIndex.value,
                  onTap: (index) => controller.selectedIndex.value = index,
                  items: [
                    SalomonBottomBarItem(
                      icon: Icon(
                        controller.selectedIndex.value == 0
                            ? Icons.shopping_bag
                            : Icons.shopping_bag_outlined,
                      ),
                      title: const Text("Produk"),
                      selectedColor: Colors.purple,
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(
                        controller.selectedIndex.value == 1
                            ? Icons.receipt_long
                            : Icons.receipt_long_outlined,
                      ),
                      title: const Text("Pesanan"),
                      selectedColor: Colors.blue,
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(
                        controller.selectedIndex.value == 2
                            ? Icons.attach_money
                            : Icons.money_outlined,
                      ),
                      title: const Text("Rekap"),
                      selectedColor: Colors.green,
                    ),
                    SalomonBottomBarItem(
                      icon: Icon(
                        controller.selectedIndex.value == 3
                            ? Icons.info
                            : Icons.info_outline,
                      ),
                      title: const Text("Info"),
                      selectedColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          )),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const ProdukPage(),
    const PesananPage(),
    const RecapPage(),
    const InfoPage(),
  ];
}
