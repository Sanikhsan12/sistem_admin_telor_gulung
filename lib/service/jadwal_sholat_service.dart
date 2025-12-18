// lib/service/sholat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SholatService {
  String get _baseUrl => dotenv.env['API_JADWAL_URL'] ?? '';

  // ! Fetch jadwal Sholat
  Future<Map<String, dynamic>?> fetchJadwalSholat(
    String idLokasi,
    String datePath,
  ) async {
    final url = Uri.parse('$_baseUrl/jadwal/$idLokasi/$datePath');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['data'];
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }
}
