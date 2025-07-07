import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/database/pesanan_database.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/pesanan.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/screens/pesanan/detail_pesanan.dart';
import 'package:thesis_app/screens/pesanan/tambah_pesanan.dart';
import 'package:thesis_app/widgets/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final PesananDatabase pesananDatabase = PesananDatabase();
  final Map<int, String> _produkCache = {};

  Future<String> getNamaProduk(int produkId) async {
    if (_produkCache.containsKey(produkId)) {
      return _produkCache[produkId]!;
    }
    final produk = await ProdukDatabase().getProdukById(produkId);
    final nama = produk?.nama_produk ?? 'Produk tidak ditemukan';
    _produkCache[produkId] = nama;
    return nama;
  }

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
          const SizedBox(height: 10), // Added space between AppBar and body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _bukaTambahPesanan(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tambah Pesanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Pesanan>>(
              stream: pesananDatabase.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // Check for common connection error messages
                  final errorMsg = snapshot.error.toString().toLowerCase();
                  if (errorMsg.contains('socket') ||
                      errorMsg.contains('network') ||
                      errorMsg.contains('failed host lookup') ||
                      errorMsg.contains('connection refused') ||
                      errorMsg.contains('no address associated')) {
                    return const Center(
                        child: Text(
                            'Tidak ada koneksi, pastikan Anda terhubung ke internet'));
                  }
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                final pesananList = (snapshot.data!)
                  ..sort(
                      (a, b) => b.tanggal_selesai.compareTo(a.tanggal_selesai));

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
                            subtitle: FutureBuilder<String>(
                              future: getNamaProduk(pesanan.produk_id),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text('Memuat nama produk...');
                                }
                                return Text(
                                  '${pesanan.jumlah} pcs x ${snapshot.data}',
                                );
                              },
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total:\nRp ${NumberFormat("#,###", "id_ID").format(pesanan.total_harga)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize:
                                        15, // Increased font size the pesanan page trailing
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            onTap: () {
                              //ke halaman detail pesanan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPesanan(pesanan: pesanan),
                                ),
                              );
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _bukaTambahPesanan(context),
      //   backgroundColor: const Color(0xFF007AFF),
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(16)),
      //   ),
      //   icon: const Icon(Icons.add, color: Colors.white),
      //   label: const Text(
      //     'Tambah Pesanan',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
    );
  }
}
