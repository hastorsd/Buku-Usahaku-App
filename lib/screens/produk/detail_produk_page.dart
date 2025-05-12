import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/screens/produk/tambah_produk.dart';

class DetailProdukPage extends StatefulWidget {
  final Produk produk;

  DetailProdukPage({super.key, required this.produk});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  final ProdukDatabase produkDatabase = ProdukDatabase();

  void _editProduk(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TambahProdukPage(
        produkDatabase: produkDatabase,
        produk: widget.produk,
      ),
    );
  }

  void _deleteProduk(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah kamu yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await produkDatabase.deleteProduk(widget.produk);
      if (context.mounted) {
        Navigator.pop(context); // keluar dari halaman detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProduk(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteProduk(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.produk.nama_produk,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.produk.gambar_url != null &&
                        widget.produk.gambar_url!.isNotEmpty
                    ? Image.network(widget.produk.gambar_url!)
                    : const Icon(Icons.image, size: 150, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceItem("Harga Jual", widget.produk.harga_jual.toInt(),
                    Colors.blue),
                _buildPriceItem("Harga Modal",
                    widget.produk.harga_modal.toInt(), Colors.green),
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
                (widget.produk.deskripsi_produk?.isNotEmpty ?? false)
                    ? widget.produk.deskripsi_produk!
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
                (widget.produk.tambahan_produk?.isNotEmpty ?? false)
                    ? widget.produk.tambahan_produk!
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
