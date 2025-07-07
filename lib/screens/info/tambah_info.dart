import 'package:flutter/material.dart';
import 'package:thesis_app/database/info_database.dart';
import 'package:thesis_app/model/info.dart';

class TambahInfo extends StatefulWidget {
  const TambahInfo({super.key});

  @override
  State<TambahInfo> createState() => _TambahInfoState();
}

class _TambahInfoState extends State<TambahInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _simpanInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now(); // waktu lokal sementara

    final infoBaru = Info(
      id: 0, // ID diabaikan karena auto increment
      userId: '', // akan ditambahkan otomatis di InfoDatabase
      judul: _judulController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await InfoDatabase().createInfo(infoBaru);

    if (mounted) {
      Navigator.pop(context); // kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Isi Catatan'),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Isi catatan tidak boleh kosong'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _simpanInfo,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
