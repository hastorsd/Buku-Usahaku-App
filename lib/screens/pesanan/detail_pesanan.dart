import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/model/pesanan.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPesanan extends StatefulWidget {
  final Pesanan pesanan;

  const DetailPesanan({super.key, required this.pesanan});

  @override
  State<DetailPesanan> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesanan> {
  Produk? _produk;

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    final produk =
        await ProdukDatabase().getProdukById(widget.pesanan.produk_id);
    if (!mounted) return; // <--- Tambahan ini penting
    setState(() {
      _produk = produk;
    });
  }

  String formatTanggal(DateTime date) {
    return DateFormat("d MMMM yyyy, HH:mm", "id_ID").format(date);
  }

  void _kirimPesanWhatsApp() async {
    // Pengecekan apakah nomor Whatsapp tidak null
    final nomorRaw = widget.pesanan.nomor_whatsapp;

    if (nomorRaw == null || nomorRaw.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap masukkan nomor WhatsApp pemesan")),
      );
      return;
    }

    final nomor = widget.pesanan.nomor_whatsapp.replaceAll(RegExp(r'^0'), '62');
    final pesan = Uri.encodeComponent("""
Halo ${widget.pesanan.nama_pemesan},

Berikut detail pesanan Anda:
- Produk: ${_produk!.nama_produk}
- Jumlah: ${widget.pesanan.jumlah} pcs
- Alamat: ${widget.pesanan.alamat}
- Tanggal Selesai: ${formatTanggal(widget.pesanan.tanggal_selesai)}
- Catatan: ${widget.pesanan.catatan}
- Tambahan Harga: Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.tambahan_harga)}
- Total Harga: Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.total_harga)}

Terima kasih 🙏
""");

    final url = Uri.parse("https://wa.me/$nomor?text=$pesan");

    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _produk == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pesanan.nama_pemesan,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  _buildDataPesanan(
                      'Produk:', _produk!.nama_produk, Colors.blue),
                  _buildDataPesanan('Jumlah:',
                      '${widget.pesanan.jumlah.toString()} pcs', Colors.blue),
                  _buildDataPesanan(
                      'Alamat:', widget.pesanan.alamat, Colors.blue),
                  _buildDataPesanan(
                      'Tanggal Selesai:',
                      formatTanggal(widget.pesanan.tanggal_selesai),
                      Colors.blue),
                  _buildDataPesanan(
                      'Catatan:', widget.pesanan.catatan, Colors.blue),
                  _buildDataPesanan(
                      'Tambahan Harga:',
                      'Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.tambahan_harga)}',
                      Colors.blue),
                  _buildDataPesanan(
                      'Total Harga:',
                      'Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.total_harga)}',
                      Colors.blue),
                  const SizedBox(height: 8),
                  _buildDataPesanan('No. Whatsapp:',
                      widget.pesanan.nomor_whatsapp, Colors.blue),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Ingin menghubungi pemesan?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp,
                              color: Colors.green, size: 40),
                          label: const Text("Hubungi via WhatsApp"),
                          onPressed: _kirimPesanWhatsApp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDataPesanan(String label, String item, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          item,
          style: TextStyle(color: color),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
