import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // import untuk format angka
import 'package:thesis_app/model/produk.dart';

class DetailProdukPage extends StatelessWidget {
  final Produk produk;

  const DetailProdukPage({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: navigasi ke halaman edit
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produk.nama_produk,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: produk.gambar_url != null && produk.gambar_url!.isNotEmpty
                  ? Image.network(produk.gambar_url!)
                  : const Icon(Icons.image, size: 150, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceItem(
                  "Harga Jual",
                  produk.harga_jual.toInt(),
                  Colors.blue,
                ),
                _buildPriceItem(
                  "Harga Modal",
                  produk.harga_modal.toInt(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Deskripsi",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (produk.deskripsi_produk?.isNotEmpty ?? false)
                    ? produk.deskripsi_produk!
                    : 'Tidak ada deskripsi',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Tambahan",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (produk.tambahan_produk?.isNotEmpty ?? false)
                    ? produk.tambahan_produk!
                    : 'Tidak ada tambahan',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, int harga, Color color) {
    final formatted = NumberFormat.decimalPattern('id').format(harga);
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Rp $formatted', style: TextStyle(color: color)),
      ],
    );
  }
}
