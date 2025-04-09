import 'package:flutter/material.dart';
import 'package:thesis_app/auth/auth_service.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/screens/produk/tambah_produk.dart';
import 'package:thesis_app/widgets/custom_appbar.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final authService = AuthService();
  final produkDatabase = ProdukDatabase();

  void tambahProdukBaru() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TambahProdukPage(produkDatabase: produkDatabase),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahProdukBaru,
        backgroundColor: const Color(0xFF007AFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Produk',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Produk>>(
              stream: produkDatabase.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final produks = snapshot.data!;

                if (produks.isEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: produks.length,
                  itemBuilder: (context, index) {
                    final produk = produks[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            produk.gambar_url != null &&
                                    produk.gambar_url!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      produk.gambar_url!,
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image,
                                    size: 80, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              produk.nama_produk,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                                'Rp ${currencyFormatter.format(produk.harga_jual)}'),
                            Text(
                                'Rp ${currencyFormatter.format(produk.harga_modal)}'),
                            Text(produk.deskripsi_produk,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text(produk.tambahan_produk,
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
