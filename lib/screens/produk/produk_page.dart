import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/auth/auth_service.dart';
import 'package:thesis_app/database/produk_database.dart';
import 'package:thesis_app/model/produk.dart';
import 'package:thesis_app/widgets/custom_appbar.dart';

// Formatter ribuan
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

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final authService = AuthService();
  final produkDatabase = ProdukDatabase();

  final namaProdukController = TextEditingController();
  final hargaJualController = TextEditingController();
  final hargaModalController = TextEditingController();
  final deskripsiProdukController = TextEditingController();
  final tambahanProdukController = TextEditingController();

  XFile? _selectedImage; // ⬅️ pindahkan ke luar agar tidak reset
  bool _isLoading = false;

  @override
  void dispose() {
    namaProdukController.dispose();
    hargaJualController.dispose();
    hargaModalController.dispose();
    deskripsiProdukController.dispose();
    tambahanProdukController.dispose();
    super.dispose();
  }

  void tambahProdukBaru() {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          _selectedImage = picked;
                        });
                        setModalState(
                            () {}); // ⬅️ Ini yang bikin modal ke-refresh
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: _selectedImage == null
                          ? const Icon(Icons.add_photo_alternate, size: 50)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Text(
                      _selectedImage!.name,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  TextField(
                    controller: namaProdukController,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                  ),
                  TextField(
                    controller: hargaJualController,
                    decoration: const InputDecoration(labelText: 'Harga Jual'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                  ),
                  TextField(
                    controller: hargaModalController,
                    decoration: const InputDecoration(labelText: 'Harga Modal'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                  ),
                  TextField(
                    controller: deskripsiProdukController,
                    decoration:
                        const InputDecoration(labelText: 'Deskripsi Produk'),
                  ),
                  TextField(
                    controller: tambahanProdukController,
                    decoration:
                        const InputDecoration(labelText: 'Tambahan Produk'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (namaProdukController.text.isEmpty ||
                                hargaJualController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Nama produk dan harga wajib diisi!'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            // Upload gambar
                            String? imageUrl;
                            if (_selectedImage != null) {
                              final bytes = await File(_selectedImage!.path)
                                  .readAsBytes();
                              final fileName = _selectedImage!.name;
                              imageUrl = await produkDatabase.uploadImage(
                                  bytes, fileName);
                            }

                            final userId =
                                Supabase.instance.client.auth.currentUser!.id;

                            final produkBaru = Produk(
                              user_id: userId,
                              nama_produk: namaProdukController.text,
                              harga_jual: parseHarga(hargaJualController.text),
                              harga_modal:
                                  parseHarga(hargaModalController.text),
                              deskripsi_produk: deskripsiProdukController.text,
                              tambahan_produk: tambahanProdukController.text,
                              gambar_url: imageUrl ?? '',
                            );

                            await produkDatabase.createProduk(produkBaru);

                            // Reset form
                            setState(() {
                              _selectedImage = null;
                              _isLoading = false;
                            });
                            Navigator.pop(context);
                            namaProdukController.clear();
                            hargaJualController.clear();
                            hargaModalController.clear();
                            deskripsiProdukController.clear();
                            tambahanProdukController.clear();
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Tambah Produk'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahProdukBaru,
        child: const Icon(Icons.add),
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
