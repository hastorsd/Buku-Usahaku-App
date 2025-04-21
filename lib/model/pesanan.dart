class Pesanan {
  int? id;
  // String user_id;
  String nama_pemesan;
  int produk_id;
  int jumlah;
  String alamat;
  DateTime tanggal_selesai;
  String catatan;
  double tambahan_harga;
  double total_harga;
  String nomor_whatsapp;

  Pesanan({
    this.id,
    // required this.user_id,
    required this.nama_pemesan,
    required this.produk_id,
    required this.jumlah,
    required this.alamat,
    required this.tanggal_selesai,
    required this.catatan,
    required this.tambahan_harga,
    required this.total_harga,
    required this.nomor_whatsapp,
  });

  Map<String, dynamic> toMap() {
    final map = {
      // 'user_id': user_id,
      'nama_pemesan': nama_pemesan,
      'produk_id': produk_id,
      'jumlah': jumlah,
      'alamat': alamat,
      'tanggal_selesai': tanggal_selesai.toIso8601String(),
      'catatan': catatan,
      'tambahan_harga': tambahan_harga,
      'total_harga': total_harga,
      'nomor_whatsapp': nomor_whatsapp,
    };
    // hanya sertakan 'id' jika tidak null
    if (id != null) map['id'] = id!;
    return map;
  }

  factory Pesanan.fromMap(Map<String, dynamic> map) {
    return Pesanan(
      id: map['id'],
      // user_id: map['user_id'],
      nama_pemesan: map['nama_pemesan'],
      produk_id: map['produk_id'],
      jumlah: map['jumlah'],
      alamat: map['alamat'],
      tanggal_selesai: DateTime.parse(map['tanggal_selesai']),
      catatan: map['catatan'],
      tambahan_harga: (map['tambahan_harga'] as num).toDouble(),
      total_harga: (map['total_harga'] as num).toDouble(),
      nomor_whatsapp: map['nomor_whatsapp'] ?? '',
    );
  }
}
