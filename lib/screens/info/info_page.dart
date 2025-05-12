import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/database/info_database.dart';
import 'package:thesis_app/model/info.dart';
import 'package:thesis_app/screens/info/detail_info_page.dart';
import 'package:thesis_app/screens/info/tambah_info.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Informasi Usaha',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<Info>>(
        stream: InfoDatabase().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    DateFormat("d MMMM y", "id").format(info.createdAt);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailInfoPage(info: info),
                      ),
                    );
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahInfo()),
          );
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
