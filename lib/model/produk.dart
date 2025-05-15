class Produk {
  int? id;
  String user_id;
  String nama_produk;
  double harga_jual;
  double harga_modal;
  String deskripsi_produk;
  String tambahan_produk;
  String gambar_url;
  final bool isDeleted;

  Produk({
    this.id,
    required this.user_id,
    required this.nama_produk,
    required this.harga_jual,
    required this.harga_modal,
    required this.deskripsi_produk,
    required this.tambahan_produk,
    required this.gambar_url,
    required this.isDeleted,
  });

  /*

  e.g. map <---> produk

  {
    'id': 1,
    'nama_produk': 'rendang',
    'harga_jual': 10000,
    'harga_modal': 5000,
    'deskripsi_produk': 'terbuat dari daging sapi',
    'tambahan_produk': 'sertifikasi halal',
  }

  Produk(
    id: 1,
    nama_produk: 'rendang',
    harga_jual: 10000,
    harga_modal: 5000,
    deskripsi_produk: 'terbuat dari daging sapi',
    tambahan_produk: 'sertifikasi halal',
  )

  */

  // map -> produk
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'],
      user_id: map['user_id'],
      nama_produk: map['nama_produk'] ?? '',
      harga_jual: (map['harga_jual'] as num).toDouble(),
      harga_modal: (map['harga_modal'] as num).toDouble(),
      deskripsi_produk: map['deskripsi_produk'] ?? '',
      tambahan_produk: map['tambahan_produk'] ?? '',
      gambar_url: map['gambar_url'],
      isDeleted: map['is_deleted'] ?? false,
    );
  }

  // produk -> map (agar bisa disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'nama_produk': nama_produk,
      'harga_jual': harga_jual,
      'harga_modal': harga_modal,
      'deskripsi_produk': deskripsi_produk,
      'tambahan_produk': tambahan_produk,
      'gambar_url': gambar_url,
      'is_deleted': isDeleted,
    };
  }
}
