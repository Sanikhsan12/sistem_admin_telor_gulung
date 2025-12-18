import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class ProductService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // ! Get All Products
  Future<List<dynamic>> fetchProducts() async {
    final url = Uri.parse('$_baseUrl/products');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  // ! Add Product (POST Multipart)
  Future<bool> addProduct(Map<String, String> body, File? imageFile) async {
    final url = Uri.parse('$_baseUrl/products');
    final token = await AuthService.getToken();

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(body);

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', imageFile.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  // ! Update Product (POST dengan _method=PUT untuk Laravel)
  Future<bool> updateProduct(
    int id,
    Map<String, String> body,
    File? imageFile,
  ) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final token = await AuthService.getToken();

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(body);
    request.fields['_method'] = 'PUT';

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', imageFile.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  // ! Delete Product
  Future<bool> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final response = await http.delete(url, headers: await _getHeaders());
    return response.statusCode == 200;
  }
}
