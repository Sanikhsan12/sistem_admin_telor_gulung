import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class UserApprovalService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ! Get Users Pending Approval (Tetap GET)
  Future<http.Response> fetchPendingApprovals() async {
    final url = Uri.parse('$_baseUrl/users?status=menunggu_approval');
    final response = await http.get(url, headers: await _getHeaders());
    return response;
  }

  // ! Approve User (Gunakan PATCH)
  Future<http.Response> approveUser(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/status');
    final response = await http.patch(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'status': 'approved'}),
    );
    return response;
  }

  // ! Reject User (Gunakan PATCH)
  Future<http.Response> rejectUser(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/status');

    final response = await http.patch(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'status': 'rejected'}),
    );
    return response;
  }
}
