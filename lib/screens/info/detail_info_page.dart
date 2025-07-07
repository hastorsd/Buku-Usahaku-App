import 'package:flutter/material.dart';
import 'package:thesis_app/model/info.dart';
import 'package:thesis_app/database/info_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

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

    try {
      await InfoDatabase().updateInfo(updatedInfo);
      // PERUBAHAN UTAMA: Hapus Navigator.of(context).pop(true) di sini
      // Kita hanya mematikan mode edit dan _isSaving
      if (mounted) {
        setState(() {
          _isEditMode = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String formatTanggal(DateTime tanggal) {
    return DateFormat("d MMMM y", 'id_ID').format(tanggal);
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
            // Ini akan tetap mempop halaman dan memberi sinyal perubahan
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await InfoDatabase().deleteInfo(widget.info.id!);
        // Ini tetap akan pop ke halaman sebelumnya dan mengirimkan 'true'
        // karena catatan memang sudah dihapus, jadi tidak ada yang tersisa untuk ditampilkan di detail.
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Catatan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus catatan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Menggunakan PopScope untuk menangani pop manual
      canPop: true, // Izinkan pop secara default
      onPopInvoked: (didPop) async {
        if (didPop) {
          // Jika pop terjadi karena gesture back atau tombol back,
          // kita perlu memastikan InfoPage mendapatkan update,
          // meskipun Supabase stream seharusnya sudah otomatis.
          // Kita bisa pop dengan sinyal 'false' atau 'null' jika tidak ada perubahan spesifik yang terjadi,
          // atau 'true' jika ada kemungkinan perubahan (misal: jika user sempat edit tapi tidak save).
          // Untuk kasus ini, default pop (tanpa hasil) sudah cukup jika tidak ada perubahan spesifik.
          // Jika Anda ingin memastikan InfoPage rebuild setiap kali kembali dari detail (tanpa save/delete),
          // Anda bisa melakukan: Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _isEditMode = true),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _konfirmasiHapus,
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
                      // Jika tidak dalam mode edit, bisa disentuh untuk masuk mode edit
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
              // Tambahkan kondisi untuk menampilkan tanggal diperbarui
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
                        // Jika tidak dalam mode edit, bisa disentuh untuk masuk mode edit
                        onTap: () => setState(() => _isEditMode = true),
                        child: SingleChildScrollView(
                          child: Linkify(
                            onOpen: (link) async {
                              final Uri url = Uri.parse(link.url);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Tidak dapat membuka ${link.url}')),
                                );
                              }
                            },
                            text: _contentController.text,
                            style: const TextStyle(fontSize: 16),
                            linkStyle: const TextStyle(color: Colors.blue),
                            options: const LinkifyOptions(
                              humanize: false,
                              defaultToHttps: true,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
