import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/database/pesanan_database.dart';
import 'package:thesis_app/model/pesanan.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/screens/pesanan/tambah_pesanan.dart';
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
    if (!mounted) return; // tambahan penting
    setState(() {
      _produk = produk;
    });
  }

  String formatTanggal(DateTime date) {
    return DateFormat("d MMMM yyyy, HH:mm", "id_ID").format(date);
  }

  void _kirimPesanWhatsApp() async {
    final nomorRaw = widget.pesanan.nomor_whatsapp;

    if (nomorRaw == null || nomorRaw.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor WhatsApp tidak tersedia")),
      );
      return;
    }

    if (_produk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data produk belum termuat")),
      );
      return;
    }

    final nomor = nomorRaw.replaceAll(RegExp(r'\D'), '');
    final nomorWa = nomor.startsWith('0') ? '62${nomor.substring(1)}' : nomor;

    final pesan = """
Halo ${widget.pesanan.nama_pemesan},

Berikut detail pesanan Anda:
- Produk: ${_produk!.nama_produk}
- Jumlah: ${widget.pesanan.jumlah} pcs
- Alamat: ${widget.pesanan.alamat}
- Tanggal Selesai: ${formatTanggal(widget.pesanan.tanggal_selesai)} WIB
- Catatan: ${widget.pesanan.catatan}
- Tambahan Harga: Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.tambahan_harga)}
- Total Harga: Rp ${NumberFormat("#,###", "id_ID").format(widget.pesanan.total_harga)}

Terima kasih, ditunggu pesanan selanjutnya!
""";

    final encodedPesan = Uri.encodeComponent(pesan);

    final uri = Uri.parse(
        "whatsapp://send?phone=$nomorWa&text=$encodedPesan"); // << intent scheme WhatsApp

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Tidak dapat membuka WhatsApp dengan URI: $uri');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Gagal membuka WhatsApp. Pastikan WhatsApp telah terinstal.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Detail Pesanan'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Material(
                      child: TambahPesanan(
                        pesananDatabase: PesananDatabase(),
                        pesanan: widget.pesanan, // mode edit
                      ),
                    ),
                  ),
                );
                setState(() {}); // Refresh data setelah edit
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Pesanan'),
                    content: const Text('Yakin ingin menghapus pesanan ini?'),
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

                if (confirm == true) {
                  await PesananDatabase().deletePesanan(widget.pesanan);
                  Navigator.pop(context); // Kembali dari halaman detail
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pesanan berhasil dihapus')),
                  );
                }
              },
            ),
          ]),
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
