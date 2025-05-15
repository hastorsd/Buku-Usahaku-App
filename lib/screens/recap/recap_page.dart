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
            return ListTile(
              title: Text('Periode: ${item['periode']}'),
              trailing: Text(
                '${item['jumlah']} pesanan',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15, // Increased font size the pesanan page trailing
                ),
              ),
              // onTap: ,
            );
          },
        );
      },
    );
  }
}

class KeuntunganTab extends StatelessWidget {
  const KeuntunganTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PesananDatabase().getRekapKeuntunganPerPeriode(),
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

            return ListTile(
              title: Text('Periode: ${item['periode']}'),
              trailing: Text(
                'Rp $formattedKeuntungan',
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
