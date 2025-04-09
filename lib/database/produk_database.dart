import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/model/produk.dart';

class ProdukDatabase {
  final database = Supabase.instance.client;

  // Upload gambar
  Future<String?> uploadImage(Uint8List fileBytes, String fileName) async {
    final bucket = 'foto-produk';
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    try {
      final result = await database.storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      if (result != null) {
        final url = database.storage.from(bucket).getPublicUrl(path);
        print('Uploaded to: $url');
        return url;
      }
    } catch (e) {
      print('Upload error: $e');
    }

    return null;
  }

  // Create
  Future createProduk(Produk tambahProduk) async {
    final userId = database.auth.currentUser!.id; // ⬅️ ambil user login
    final data = tambahProduk.toMap()..['user_id'] = userId;
    await database.from('produk').insert(data);
  }

  // Read hanya produk milik user
  final stream = Supabase.instance.client
      .from('produk')
      .stream(primaryKey: ['id'])
      .eq('user_id',
          Supabase.instance.client.auth.currentUser!.id) // ⬅️ filter user
      .map((data) =>
          data.map((produkMap) => Produk.fromMap(produkMap)).toList());

  // Update
  Future updateProduk(
    Produk produkLama,
    String namaProdukBaru,
    double hargaJualBaru,
    double hargaModalBaru,
    String deskripsiProdukBaru,
    String tambahanProdukBaru,
  ) async {
    await database.from('produk').update({
      'nama_produk': namaProdukBaru,
      'harga_jual': hargaJualBaru,
      'harga_modal': hargaModalBaru,
      'deskripsi_produk': deskripsiProdukBaru,
      'tambahan_produk': tambahanProdukBaru,
    }).eq('id', produkLama.id!);
  }

  // Delete
  Future deleteProduk(Produk produk) async {
    await database.from('produk').delete().eq('id', produk.id!);
  }
}
