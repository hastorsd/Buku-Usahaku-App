import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/produk.dart';

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

  const TambahProdukPage({super.key, required this.produkDatabase});

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

  Future<void> _submitProduk() async {
    if (_namaController.text.isEmpty || _jualController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Peringatan!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text('Nama produk dan harga wajib diisi!'),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });

      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      final bytes = await File(_selectedImage!.path).readAsBytes();
      imageUrl =
          await widget.produkDatabase.uploadImage(bytes, _selectedImage!.name);
    }

    final userId = Supabase.instance.client.auth.currentUser!.id;
    final produk = Produk(
      user_id: userId,
      nama_produk: _namaController.text,
      harga_jual: parseHarga(_jualController.text),
      harga_modal: parseHarga(_modalController.text),
      deskripsi_produk: _deskripsiController.text,
      tambahan_produk: _tambahanController.text,
      gambar_url: imageUrl ?? '',
    );

    await widget.produkDatabase.createProduk(produk);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('Tambah Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _selectedImage = picked);
                }
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 225, 225, 225),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(Icons.camera_alt, color: Colors.grey))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImage!.path),
                            fit: BoxFit.cover),
                      ),
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
                    : const Text('Tambah Produk',
                        style: TextStyle(color: Colors.white)),
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
          hintText:
              label == 'Harga Jual' || label == 'Harga Modal' ? 'Rp.' : '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
