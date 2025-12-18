import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/user_approval_service.dart';

class UserApprovalPage extends StatefulWidget {
  const UserApprovalPage({super.key});

  @override
  State<UserApprovalPage> createState() => _UserApprovalPageState();
}

class _UserApprovalPageState extends State<UserApprovalPage> {
  final UserApprovalService _service = UserApprovalService();

  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // !  ambil data dari Service
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _service.fetchPendingApprovals();

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _pendingUsers = body['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        _showSnackBar('Gagal mengambil data: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ! Fungsi Approve
  Future<void> _approveUser(int id) async {
    try {
      final response = await _service.approveUser(id);
      if (response.statusCode == 200) {
        _showSnackBar('User berhasil di-approve!', isError: false);
        if (mounted) _fetchData(); // Refresh list
      } else {
        _showSnackBar('Gagal approve user');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  // ! Fungsi Reject
  Future<void> _rejectUser(int id) async {
    try {
      final response = await _service.rejectUser(id);
      if (response.statusCode == 200) {
        _showSnackBar('User telah ditolak/reject.', isError: true);
        if (mounted) _fetchData(); // Refresh list
      } else {
        _showSnackBar('Gagal reject user');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Approval",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.blue,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pendingUsers.isEmpty
            ? const Center(child: Text("Tidak ada user pending"))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _pendingUsers.length,
                itemBuilder: (context, index) {
                  final user = _pendingUsers[index];
                  // ? Pastikan backend mengirim 'id', 'name', 'email'
                  final int userId = user['id'];
                  final String name = user['name'] ?? 'No Name';
                  final String email = user['email'] ?? '-';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ! Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // * Tombol Reject
                              OutlinedButton.icon(
                                onPressed: () => _rejectUser(userId),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text("Reject"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // * Tombol Approve
                              ElevatedButton.icon(
                                onPressed: () => _approveUser(userId),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
