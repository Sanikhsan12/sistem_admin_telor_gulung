class ProductModel {
  final String nama_produk;
  final int ketersediaan_stok;
  final String description;
  final int harga;
  final String foto;

  ProductModel({
    required this.nama_produk,
    required this.ketersediaan_stok,
    required this.description,
    required this.harga,
    required this.foto,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      nama_produk: json['nama_produk'],
      ketersediaan_stok: json['ketersediaan_stok'],
      description: json['description'],
      harga: json['harga'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_produk': nama_produk,
      'ketersediaan_stok': ketersediaan_stok,
      'description': description,
      'harga': harga,
      'foto': foto,
    };
  }
}
