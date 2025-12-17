import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserApprovalService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ! Get Users Pending Approval
  Future<http.Response> fetchPendingApprovals() async {
    final url = Uri.parse('$_baseUrl/users/pending-approvals');
    final response = await http.get(url);
    return response;
  }

  // ! Approve User by ID
  Future<http.Response> approveUser(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/approve');
    final response = await http.post(url);
    return response;
  }

  // ! Reject User by ID
  Future<http.Response> rejectUser(int userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId/reject');
    final response = await http.post(url);
    return response;
  }
}
