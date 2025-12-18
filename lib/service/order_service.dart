import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class OrderService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ! Get Orders (Bisa Filter Status)
  Future<http.Response> fetchOrders({String? status}) async {
    // * Backend Laravel: /api/orders?status=menunggu_antrian
    String urlStr = '$_baseUrl/orders';
    if (status != null && status.isNotEmpty) {
      // * Ubah spasi jadi underscore (misal: "menunggu antrian" -> "menunggu_antrian")
      final safeStatus = status.replaceAll(' ', '_');
      urlStr += '?status=$safeStatus';
    }

    final url = Uri.parse(urlStr);
    final response = await http.get(url, headers: await _getHeaders());
    return response;
  }

  // ! Get Order by ID
  Future<http.Response> fetchOrderById(int orderId) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');
    final response = await http.get(url, headers: await _getHeaders());
    return response;
  }

  // ! Update status order
  Future<http.Response> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    // * Backend Laravel: PUT /api/orders/{id}/status
    final url = Uri.parse('$_baseUrl/orders/$orderId/status');

    // * Pastikan status pakai underscore
    final safeStatus = status.replaceAll(' ', '_');

    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'status': safeStatus}),
    );
    return response;
  }
}
