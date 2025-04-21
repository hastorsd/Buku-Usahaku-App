import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/database/pesanan_database.dart';
import 'package:thesis_app/model/pesanan.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/screens/pesanan/tambah_pesanan.dart';
import 'package:thesis_app/widgets/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class PesananPage extends StatelessWidget {
  PesananPage({super.key});

  final PesananDatabase pesananDatabase = PesananDatabase();

  String formatTanggal(DateTime date) {
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

  void _bukaTambahPesanan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TambahPesanan(pesananDatabase: pesananDatabase),
    );
  }

  String formatNomorWhatsapp(String nomor) {
    // Hapus semua karakter non-digit
    nomor = nomor.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika diawali 0 → ganti dengan 62
    if (nomor.startsWith('0')) {
      nomor = '62${nomor.substring(1)}';
    }

    return nomor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pesanan',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Pesanan>>(
              stream: pesananDatabase.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                final pesananList = snapshot.data ?? [];

                if (pesananList.isEmpty) {
                  return const Center(child: Text('Belum ada pesanan.'));
                }

                final grouped = <String, List<Pesanan>>{};
                for (var pesanan in pesananList) {
                  final key = formatTanggal(pesanan.tanggal_selesai);
                  grouped.putIfAbsent(key, () => []).add(pesanan);
                }

                return ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final tanggal = grouped.keys.elementAt(index);
                    final pesananGroup = grouped[tanggal]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            tanggal,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...pesananGroup.map(
                          (pesanan) => ListTile(
                            title: Text(
                              pesanan.nama_pemesan,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${pesanan.jumlah} pcs\n${pesanan.catatan} x ${pesanan.produk_id}',
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total:\nRp ${NumberFormat("#,###", "id_ID").format(pesanan.total_harga)}',
                                  style: const TextStyle(color: Colors.blue),
                                  textAlign: TextAlign.right,
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Icon(Icons.message,
                                        color: Colors.green, size: 20),
                                  ),
                                  onTap: () {
                                    final pesan = Uri.encodeComponent(
                                        '''Halo ${pesanan.nama_pemesan}, berikut detail pesanan Anda: 
Produk: ${pesanan.jumlah} pcs
Alamat: ${pesanan.alamat}
Catatan: ${pesanan.catatan}
Total: Rp ${NumberFormat("#,###", "id_ID").format(pesanan.total_harga)}
Tanggal Selesai: ${formatTanggal(pesanan.tanggal_selesai)}''');

                                    // Format nomor WhatsApp
                                    final nomor = formatNomorWhatsapp(
                                        pesanan.nomor_whatsapp);

                                    final url =
                                        'https://api.whatsapp.com/send?phone=$nomor&text=$pesan';

                                    launchUrl(Uri.parse(url));
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: navigasi ke detail pesanan
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaTambahPesanan(context),
        backgroundColor: const Color(0xFF007AFF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Pesanan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
