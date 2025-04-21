import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/model/pesanan.dart';

class PesananDatabase {
  final database = Supabase.instance.client;

  // create pesanan
  Future createPesanan(Pesanan tambahPesanan) async {
    final userId = database.auth.currentUser!.id;
    final data = tambahPesanan.toMap()
      ..['user_id'] = userId; // pakai .. biar menyingkat
    /* sama aja kaya data['user_id'] = userId; */
    await database.from('pesanan').insert(data);
  }

  // read pesanan per user
  final stream = Supabase.instance.client
      .from('pesanan')
      .stream(primaryKey: ['id'])
      .eq('user_id',
          Supabase.instance.client.auth.currentUser!.id) // filter user
      .map((data) =>
          data.map((pesananMap) => Pesanan.fromMap(pesananMap)).toList());

  // update pesanan
  Future updatePesanan(
    Pesanan pesananLama,
    String namaPemesanBaru,
    String alamatBaru,
    DateTime tanggalSelesaiBaru,
    String catatanBaru,
    double tambahanHargaBaru,
    double totalHargaBaru,
  ) async {
    await database.from('pesanan').update({
      'nama_pemesan': namaPemesanBaru,
      'alamat': alamatBaru,
      'tanggal_selesai': tanggalSelesaiBaru.toIso8601String(),
      'catatan': catatanBaru,
      'tambahan_harga': tambahanHargaBaru,
      'total_harga': totalHargaBaru,
    }).eq('id', pesananLama.id!);
  }

  // delete pesanan
  Future deletePesanan(Pesanan pesanan) async {
    await database.from('pesanan').delete().eq('id', pesanan.id!);
  }
}
