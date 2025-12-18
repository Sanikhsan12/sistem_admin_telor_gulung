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
      'Authorization': 'Bearer $token',
    };
  }

  // ! Get Users Pending Approval
  Future<http.Response> fetchPendingApprovals() async {
    // * Backend: GET /api/users?status=menunggu_approval
    final url = Uri.parse('$_baseUrl/users?status=menunggu_approval');
    final response = await http.get(url, headers: await _getHeaders());
    return response;
  }

  // ! Approve User
  Future<http.Response> approveUser(int userId) async {
    // * Backend: PUT /api/users/{id}/status body: {status: approved}
    final url = Uri.parse('$_baseUrl/users/$userId/status');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'status': 'approved'}),
    );
    return response;
  }

  // ! Reject User
  Future<http.Response> rejectUser(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/status');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'status': 'rejected'}),
    );
    return response;
  }
}
