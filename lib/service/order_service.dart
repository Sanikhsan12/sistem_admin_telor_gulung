import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrderService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ! Get Orders
  Future<http.Response> fetchOrders() async {
    final url = Uri.parse('$_baseUrl/orders');
    final response = await http.get(url);
    return response;
  }

  // ! Get Order by ID
  Future<http.Response> fetchOrderById(int orderId) async {
    final url = Uri.parse('$_baseUrl/orders/$orderId');
    final response = await http.get(url);
    return response;
  }

  // ! Update status order by productId
  Future<http.Response> updateOrderStatus({
    required int productId,
    required String status,
  }) async {
    final url = Uri.parse('$_baseUrl/orders/$productId/status');
    final payload = {'status': status};
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return response;
  }
}
