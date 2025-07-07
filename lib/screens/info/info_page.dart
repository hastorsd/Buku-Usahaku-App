import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/database/info_database.dart';
import 'package:thesis_app/model/info.dart';
import 'package:thesis_app/screens/info/detail_info_page.dart';
import 'package:thesis_app/screens/info/tambah_info.dart';
import 'package:thesis_app/widgets/logout_icon.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Catatan Informasi Usaha',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: LogoutIcon(),
      ),
      body: StreamBuilder<List<Info>>(
        stream: InfoDatabase().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan'));
          }

          final infos = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: infos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // tampil 2 kolom
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                final info = infos[index];
                final formatted =
                    DateFormat("d MMMM y", "id_ID").format(info.createdAt);
                return GestureDetector(
                  onTap: () async {
                    // Tunggu hasil dari halaman detail.
                    // Jika catatan dihapus, `DetailInfoPage` akan mengembalikan `true`.
                    final bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailInfoPage(info: info),
                      ),
                    );
                    // Kita memanggil setState() di InfoPage. Ini akan memicu
                    // StreamBuilder untuk memeriksa stream Supabase lagi.
                    // Walaupun Supabase stream sudah real-time, ini membantu
                    // memastikan UI terupdate setelah kembali dari halaman detail.
                    if (result == true || result == false || result == null) {
                      setState(() {
                        // Tidak ada logic khusus di sini, hanya memicu rebuild
                      });
                    }
                  },
                  child: Card(
                    elevation: 2,
                    color: Colors.amber.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              info.content,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Dibuat: $formatted',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Sama seperti di atas, tunggu hasil dari halaman tambah catatan.
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahInfo()),
          );
          if (result == true || result == false || result == null) {
            setState(() {
              // Memicu rebuild InfoPage
            });
          }
        },
        backgroundColor: const Color(0xFF007AFF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Catatan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
