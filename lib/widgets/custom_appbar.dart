import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/auth/auth_service.dart';
import 'package:thesis_app/widgets/logout_icon.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? titleOverride;

  const CustomAppBar({Key? key, this.titleOverride}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService authService = AuthService();

  bool isDarkMode = false;

  String getGreeting() {
    final now = DateTime.now();
    final hour = int.parse(DateFormat('kk').format(now));

    if (hour >= 0 && hour < 12) return 'Selamat Pagi ✨';
    if (hour >= 12 && hour < 15) return 'Selamat Siang 🌞';
    if (hour >= 15 && hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌛';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(widget.titleOverride ?? getGreeting()),
        leading: LogoutIcon());
  }
}
