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

  /* INI ADALAH FUNGSI UNTUK REKAP PENJUALAN PRODUK*/
// Ambil total penjualan per produk
  Future<List<Map<String, dynamic>>> getRekapPenjualanPerProduk() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final result = await Supabase.instance.client
        .from('pesanan')
        .select('produk_id, produk(nama_produk), jumlah')
        .eq('user_id', userId);

    // Hitung total jumlah per produk_id
    final Map<int, Map<String, dynamic>> rekap = {};

    for (var item in result) {
      final id = item['produk_id'];
      final nama = item['produk']['nama_produk'];
      final jumlah = item['jumlah'];

      if (rekap.containsKey(id)) {
        rekap[id]!['jumlah'] += jumlah;
      } else {
        rekap[id] = {'produk_id': id, 'nama_produk': nama, 'jumlah': jumlah};
      }
    }

    return rekap.values.toList();
  }

  /* INI ADALAH FUNGSI UNTUK REKAP PESANAN */
  Future<List<Map<String, dynamic>>> getRekapPesananPerPeriode() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final result = await Supabase.instance.client
        .from('pesanan')
        .select('tanggal_selesai')
        .eq('user_id', userId);

    // Rekap per bulan
    final Map<String, int> rekap = {};

    for (var item in result) {
      final DateTime tanggal = DateTime.parse(item['tanggal_selesai']);
      final String key =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}';

      if (rekap.containsKey(key)) {
        rekap[key] = rekap[key]! + 1;
      } else {
        rekap[key] = 1;
      }
    }

    // Convert to list of maps
    return rekap.entries
        .map((e) => {'periode': e.key, 'jumlah': e.value})
        .toList();
  }

  /* INI ADALAH FUNGSI UNTUK REKAP KEUNTUNGAN*/
  Future<List<Map<String, dynamic>>> getRekapKeuntunganPerPeriode() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final result = await Supabase.instance.client
        .from('pesanan')
        .select('tanggal_selesai, jumlah, total_harga, produk(harga_modal)')
        .eq('user_id', userId);

    final Map<String, double> rekap = {};

    for (var item in result) {
      final DateTime tanggal = DateTime.parse(item['tanggal_selesai']);
      final String key =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}';

      final int jumlah = item['jumlah'] ?? 0;
      final double totalHarga = (item['total_harga'] ?? 0).toDouble();
      final double hargaModal =
          (item['produk']?['harga_modal'] ?? 0).toDouble();

      final double keuntungan = totalHarga - (jumlah * hargaModal);

      if (rekap.containsKey(key)) {
        rekap[key] = rekap[key]! + keuntungan;
      } else {
        rekap[key] = keuntungan;
      }
    }

    return rekap.entries
        .map((e) => {'periode': e.key, 'keuntungan': e.value})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPesananPeriodeDetail(
      String periode) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final result = await Supabase.instance.client
        .from('pesanan')
        .select(
            'nama_pemesan, jumlah, total_harga, produk(nama_produk, harga_modal), tanggal_selesai')
        .eq('user_id', userId);

    return result.where((item) {
      final DateTime tanggal = DateTime.parse(item['tanggal_selesai']);
      final key = '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}';
      return key == periode;
    }).map((item) {
      return {
        'nama_pemesan': item['nama_pemesan'],
        'jumlah': item['jumlah'],
        'total_harga': (item['total_harga'] ?? 0).toDouble(),
        'nama_produk': item['produk']?['nama_produk'] ?? '',
        'produk': {
          'harga_modal': item['produk']?['harga_modal'] ?? 0,
        }
      };
    }).toList();
  }
}
