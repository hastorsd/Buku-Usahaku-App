import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final currencyFormatter = NumberFormat('#,##0', 'id_ID');

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanText = newValue.text.replaceAll('.', '');
    final numValue = int.tryParse(cleanText);
    if (numValue == null) return oldValue;

    final formatted = currencyFormatter.format(numValue);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

double parseHarga(String hargaFormatted) {
  return double.tryParse(hargaFormatted.replaceAll('.', '')) ?? 0.0;
}

class TambahProdukPage extends StatefulWidget {
  final ProdukDatabase produkDatabase;
  final Produk? produk;

  const TambahProdukPage(
      {super.key, required this.produkDatabase, this.produk});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _namaController = TextEditingController();
  final _jualController = TextEditingController();
  final _modalController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tambahanController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;
  final picker = ImagePicker();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _namaController.text = widget.produk!.nama_produk;
      _jualController.text =
          currencyFormatter.format(widget.produk!.harga_jual.toInt());
      _modalController.text =
          currencyFormatter.format(widget.produk!.harga_modal.toInt());
      _deskripsiController.text = widget.produk!.deskripsi_produk ?? '';
      _tambahanController.text = widget.produk!.tambahan_produk ?? '';
      _imageUrl = widget.produk!.gambar_url;
    }
  }

  Future<Uint8List?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 70, // bisa disesuaikan antara 0 - 100
      format: CompressFormat.jpeg,
    );
    return result;
  }

  Future<void> _submitProduk() async {
    if (_namaController.text.isEmpty || _jualController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Peringatan!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text('Nama produk dan harga wajib diisi!'),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
      });

      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl = _imageUrl;
    if (_selectedImage != null) {
      final file = File(_selectedImage!.path);
      final compressedBytes = await compressImage(file);

      if (compressedBytes != null) {
        imageUrl = await widget.produkDatabase.uploadImage(
          compressedBytes,
          _selectedImage!.name,
        );
      }
    }

    final userId = Supabase.instance.client.auth.currentUser!.id;

    if (widget.produk != null) {
      // UPDATE
      await widget.produkDatabase.updateProduk(widget.produk!.id.toString(), {
        'user_id': userId,
        'nama_produk': _namaController.text,
        'harga_jual': parseHarga(_jualController.text),
        'harga_modal': parseHarga(_modalController.text),
        'deskripsi_produk': _deskripsiController.text,
        'tambahan_produk': _tambahanController.text,
        'gambar_url': imageUrl ?? '',
      });
    } else {
      // INSERT BARU
      final produk = Produk(
        user_id: userId,
        nama_produk: _namaController.text,
        harga_jual: parseHarga(_jualController.text),
        harga_modal: parseHarga(_modalController.text),
        deskripsi_produk: _deskripsiController.text,
        tambahan_produk: _tambahanController.text,
        gambar_url: imageUrl ?? '',
        isDeleted: false,
      );
      await widget.produkDatabase.createProduk(produk);
    }

    if (mounted) Navigator.pop(context, true); // biar data edit langsung muncul
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.produk != null;
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(isEdit ? 'Edit Produk' : 'Tambah Produk',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pilih Sumber Gambar'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            GestureDetector(
                              child: const Row(
                                children: [
                                  Icon(Icons.image),
                                  SizedBox(width: 8),
                                  Text('Ambil dari Galeri'),
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final picked = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() => _selectedImage = picked);
                                }
                              },
                            ),
                            const Padding(padding: EdgeInsets.all(8.0)),
                            GestureDetector(
                              child: const Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text('Ambil dari Kamera'),
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final picked = await picker.pickImage(
                                    source: ImageSource.camera);
                                if (picked != null) {
                                  setState(() => _selectedImage = picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 225, 225, 225),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImage!.path),
                            fit: BoxFit.cover),
                      )
                    : (_imageUrl != null && _imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_imageUrl!, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Icon(Icons.camera_alt, color: Colors.grey))),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Nama Produk', _namaController, TextInputType.text),
            _buildTextField(
                'Harga Jual', _jualController, TextInputType.number),
            _buildTextField(
                'Harga Modal', _modalController, TextInputType.number),
            _buildTextField(
                'Deskripsi', _deskripsiController, TextInputType.text,
                maxLines: 4),
            _buildTextField(
                'Tambahan', _tambahanController, TextInputType.text),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduk,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Simpan Perubahan' : 'Simpan Produk',
                        style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters:
            keyboardType == TextInputType.number ? [ThousandsFormatter()] : [],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey), // Label color grey
          hintText:
              label == 'Harga Jual' || label == 'Harga Modal' ? 'Rp.' : '',
          hintStyle: const TextStyle(color: Colors.grey), // Hint color grey
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
