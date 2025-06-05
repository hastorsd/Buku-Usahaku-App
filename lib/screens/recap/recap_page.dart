import 'package:flutter/material.dart';
import 'package:thesis_app/database/pesanan_database.dart';

class RecapPage extends StatefulWidget {
  const RecapPage({super.key});

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekapitulasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          splashFactory: NoSplash.splashFactory, // ← tambahkan ini
          overlayColor: WidgetStateProperty.all(
              Colors.transparent), // ← hilangkan warna overlay
          tabs: const [
            Tab(text: 'Penjualan'),
            Tab(text: 'Pesanan'),
            Tab(text: 'Keuntungan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PenjualanTab(),
          PesananTab(),
          KeuntunganTab(),
        ],
      ),
    );
  }
}

// Placeholder tab widgets untuk masing masing fitur
class PenjualanTab extends StatelessWidget {
  const PenjualanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PesananDatabase().getRekapPenjualanPerProduk(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada penjualan'));
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              title: Text(item['nama_produk']),
              trailing: Text(
                '${item['jumlah']} terjual',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15, // Increased font size the pesanan page trailing
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PesananTab extends StatelessWidget {
  const PesananTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PesananDatabase().getRekapPesananPerPeriode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada data pesanan'));
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final String periode = item['periode'] ?? 'Tidak diketahui';
            final int jumlah = item['jumlah'];

            return ExpansionTile(
              title: Text('Periode: $periode'),
              trailing: Text(
                '$jumlah pesanan',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: PesananDatabase().getPesananPeriodeDetail(periode),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data!.isEmpty) {
                      return const ListTile(
                          title: Text('Tidak ada data pesanan.'));
                    }

                    return Column(
                      children: detailSnapshot.data!.map((e) {
                        final String namaPemesan =
                            e['nama_pemesan'] ?? 'Tanpa nama';
                        final String namaProduk =
                            e['nama_produk'] ?? 'Produk tidak dikenal';
                        final int jumlah = e['jumlah'] ?? 0;
                        final String tanggalFormat =
                            e['tanggal_selesai'] ?? 'Tanggal tidak tersedia';

                        return ListTile(
                          title: Text(
                            '$namaPemesan ($namaProduk)',
                            style: const TextStyle(color: Colors.blue),
                          ),
                          subtitle: Text(
                            'Tanggal: $tanggalFormat',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 99, 99, 99)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}

class KeuntunganTab extends StatefulWidget {
  const KeuntunganTab({super.key});

  @override
  State<KeuntunganTab> createState() => _KeuntunganTabState();
}

class _KeuntunganTabState extends State<KeuntunganTab> {
  late Future<List<Map<String, dynamic>>> _rekapFuture;

  @override
  void initState() {
    super.initState();
    _rekapFuture = PesananDatabase().getRekapKeuntunganPerPeriode();
  }

  @override
  Widget build(BuildContext context) {
    String formatRupiah(dynamic value) {
      final number =
          value is String ? double.tryParse(value) : value.toDouble();
      if (number == null) return 'Rp 0';
      return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _rekapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada data keuntungan'));
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final formattedKeuntungan =
                item['keuntungan'].toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]}.',
                    );
            final String periode = item['periode'];

            return ExpansionTile(
              title: Text('Periode: $periode'),
              trailing: Text(
                'Rp $formattedKeuntungan',
                style: const TextStyle(color: Colors.blue, fontSize: 15),
              ),
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: PesananDatabase().getPesananPeriodeDetail(periode),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!detailSnapshot.hasData ||
                        detailSnapshot.data!.isEmpty) {
                      return const ListTile(
                          title: Text('Tidak ada transaksi.'));
                    }

                    return Column(
                      children: detailSnapshot.data!.map((e) {
                        final jumlah = e['jumlah'] ?? 0;
                        final totalHarga = (e['total_harga'] ?? 0).toDouble();
                        final hargaModal =
                            (e['produk']?['harga_modal'] ?? 0).toDouble();
                        final labaBersih = totalHarga - (jumlah * hargaModal);

                        return ListTile(
                          title: Text(
                            '${e['nama_pemesan']} (${e['nama_produk']})',
                            style: const TextStyle(color: Colors.blue),
                          ),
                          subtitle: Text(
                            'Jumlah: $jumlah | Total: ${formatRupiah(totalHarga)} | Laba bersih: ${formatRupiah(labaBersih)}',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 99, 99, 99)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}
