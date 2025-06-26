import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thesis_app/database/pesanan_database.dart';
import 'package:thesis_app/model/pesanan.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/produk.dart';

class TambahPesanan extends StatefulWidget {
  final PesananDatabase pesananDatabase;
  final Pesanan? pesanan; // Tambahan: null berarti tambah, ada berarti edit

  const TambahPesanan({
    super.key,
    required this.pesananDatabase,
    this.pesanan,
  });

  @override
  State<TambahPesanan> createState() => _TambahPesananState();
}

class _TambahPesananState extends State<TambahPesanan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPemesanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _tambahanHargaController =
      TextEditingController();
  final TextEditingController _nomorWhatsappController =
      TextEditingController();

  int jumlah = 1;
  DateTime? tanggalSelesai;

  List<Produk> _produkList = [];
  Produk? _selectedProduk;

  @override
  void initState() {
    super.initState();
    _loadProduk().then((_) {
      // Inisialisasi form jika mode edit
      if (widget.pesanan != null) {
        final p = widget.pesanan!;
        _namaPemesanController.text = p.nama_pemesan;
        _alamatController.text = p.alamat;
        _catatanController.text = p.catatan ?? '';
        _tambahanHargaController.text = p.tambahan_harga.toString();
        _nomorWhatsappController.text = p.nomor_whatsapp ?? '';
        jumlah = p.jumlah;
        tanggalSelesai = p.tanggal_selesai;

        // Temukan produk yang sesuai dari list
        try {
          _selectedProduk =
              _produkList.firstWhere((produk) => produk.id == p.produk_id);
        } catch (_) {
          _selectedProduk = _produkList.isNotEmpty ? _produkList.first : null;
        }

        setState(() {});
      }
    });
  }

  Future<void> _loadProduk() async {
    final list = await ProdukDatabase().stream.first;
    setState(() {
      _produkList = list;
    });
  }

  @override
  void dispose() {
    _namaPemesanController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    _tambahanHargaController.dispose();
    _nomorWhatsappController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: tanggalSelesai ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(tanggalSelesai ?? now),
      );
      if (time != null) {
        setState(() {
          tanggalSelesai = DateTime(
            selected.year,
            selected.month,
            selected.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _simpanPesanan() async {
    if (_formKey.currentState!.validate() &&
        tanggalSelesai != null &&
        _selectedProduk != null) {
      final tambahanHarga = double.tryParse(_tambahanHargaController.text) ?? 0;

      final totalHarga = (_selectedProduk!.harga_jual * jumlah) + tambahanHarga;

      final pesanan = Pesanan(
        id: widget.pesanan?.id,
        nama_pemesan: _namaPemesanController.text,
        produk_id: _selectedProduk!.id!,
        jumlah: jumlah,
        alamat: _alamatController.text,
        tanggal_selesai: tanggalSelesai!,
        catatan: _catatanController.text,
        tambahan_harga: tambahanHarga,
        nomor_whatsapp: _nomorWhatsappController.text,
        total_harga: totalHarga,
      );

      if (widget.pesanan == null) {
        await widget.pesananDatabase.createPesanan(pesanan);
      } else {
        await widget.pesananDatabase.updatePesanan(widget.pesanan!, pesanan);
      }

      Navigator.pop(context); // kembali setelah simpan
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = tanggalSelesai != null
        ? DateFormat('dd MMM yyyy – HH:mm').format(tanggalSelesai!)
        : 'Pilih tanggal & waktu';

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.pesanan == null ? 'Tambah Pesanan' : 'Edit Pesanan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Produk>(
                value: _selectedProduk,
                items: _produkList.map((produk) {
                  return DropdownMenuItem(
                    value: produk,
                    child: Text(produk.nama_produk),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduk = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Pilih Produk'),
                validator: (value) =>
                    value == null ? 'Wajib memilih produk' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaPemesanController,
                decoration: const InputDecoration(labelText: 'Nama Pemesan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Jumlah'),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (jumlah > 1) jumlah--;
                      });
                    },
                  ),
                  Text(jumlah.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        jumlah++;
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat Pemesan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(dateStr),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pilihTanggal,
              ),
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              TextFormField(
                controller: _tambahanHargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Tambahan Harga (opsional)'),
              ),
              TextFormField(
                controller: _nomorWhatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Nomor Whatsapp (opsional)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _simpanPesanan,
                child: Text(widget.pesanan == null
                    ? 'Simpan Pesanan'
                    : 'Perbarui Pesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
