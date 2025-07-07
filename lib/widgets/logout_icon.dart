import 'package:flutter/material.dart';
import 'package:thesis_app/auth/auth_service.dart';

class LogoutIcon extends StatelessWidget {
  const LogoutIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings_outlined, color: Colors.blue),
      onSelected: (String result) async {
        if (result == 'keluar') {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text('Keluar',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await authService.signOut();
                        },
                      ),
                    ],
                  ));
        }
      },
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'keluar',
          child: Text('Keluar'),
        ),
      ],
    );
  }
}
