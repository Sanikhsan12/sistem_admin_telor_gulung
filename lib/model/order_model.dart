class OrderModel {
  final int user_id;
  final int product_id;
  final int total_barang;
  final bool balado;
  final bool keju;
  final bool pedas;
  final bool asin;
  final bool barbeque;
  final int total_harga;
  final String status;

  OrderModel({
    required this.user_id,
    required this.product_id,
    required this.total_barang,
    required this.balado,
    required this.keju,
    required this.pedas,
    required this.asin,
    required this.barbeque,
    required this.total_harga,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      user_id: json['user_id'] as int,
      product_id: json['product_id'] as int,
      total_barang: json['total_barang'] as int,
      balado: json['balado'] as bool,
      keju: json['keju'] as bool,
      pedas: json['pedas'] as bool,
      asin: json['asin'] as bool,
      barbeque: json['barbeque'] as bool,
      total_harga: json['total_harga'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'product_id': product_id,
      'total_barang': total_barang,
      'balado': balado,
      'keju': keju,
      'pedas': pedas,
      'asin': asin,
      'barbeque': barbeque,
      'total_harga': total_harga,
      'status': status,
    };
  }
}
