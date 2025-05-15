import 'package:flutter/material.dart';
import 'package:thesis_app/model/info.dart';
import 'package:thesis_app/database/info_database.dart';
import 'package:intl/intl.dart';

class DetailInfoPage extends StatefulWidget {
  final Info info;

  const DetailInfoPage({super.key, required this.info});

  @override
  State<DetailInfoPage> createState() => _DetailInfoPageState();
}

class _DetailInfoPageState extends State<DetailInfoPage> {
  late TextEditingController _judulController;
  late TextEditingController _contentController;
  bool _isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.info.judul);
    _contentController = TextEditingController(text: widget.info.content);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    setState(() => _isSaving = true);

    final updatedInfo = Info(
      id: widget.info.id,
      userId: widget.info.userId,
      judul: _judulController.text,
      content: _contentController.text,
      createdAt: widget.info.createdAt,
      updatedAt: DateTime.now(),
    );

    await InfoDatabase().updateInfo(updatedInfo);
    setState(() {
      _isEditMode = false;
      _isSaving = false;
    });
  }

  String formatTanggal(DateTime tanggal) {
    return DateFormat("d MMMM yyyy", 'id_ID').format(tanggal);
  }

  void _konfirmasiHapus() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await InfoDatabase().deleteInfo(widget.info.id!);
      if (mounted) Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSaving ? null : _simpanPerubahan,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _konfirmasiHapus,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditMode
                ? TextField(
                    controller: _judulController,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Judul catatan',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textAlign: TextAlign.start,
                  )
                : GestureDetector(
                    onTap: () => setState(() => _isEditMode = true),
                    child: Text(
                      _judulController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${formatTanggal(widget.info.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (widget.info.createdAt != widget.info.updatedAt)
              Text(
                'Diperbarui: ${formatTanggal(widget.info.updatedAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isEditMode
                  ? TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Isi catatan...',
                      ),
                      style: const TextStyle(fontSize: 16),
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isEditMode = true),
                      child: SingleChildScrollView(
                        child: Text(
                          _contentController.text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
