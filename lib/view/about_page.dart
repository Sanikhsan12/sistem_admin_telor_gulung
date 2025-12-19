import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Informasi API & Endpoint",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.blue,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Base URL : https://backendsistemtelorgulung-production.up.railway.app/api \n\n Jadwal Sholat Base URL : https://api.myquran.com/v2/sholat",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Auth Service
          _buildServiceSection("Auth Service", Icons.lock, [
            _Endpoint("POST", "/register", "Registrasi user baru"),
            _Endpoint("POST", "/login", "Login & mendapatkan Token"),
          ]),

          // 2. Product Service
          _buildServiceSection("Product Service", Icons.shopping_bag, [
            _Endpoint("GET", "/products", "Mengambil semua data produk"),
            _Endpoint("POST", "/products", "Tambah produk (Multipart)"),
            _Endpoint(
              "POST",
              "/products/{id}",
              "Update produk (Method: PUT via POST)",
            ),
            _Endpoint("DELETE", "/products/{id}", "Hapus produk"),
          ]),

          // 3. Order Service
          _buildServiceSection("Order Service", Icons.shopping_cart, [
            _Endpoint("GET", "/orders", "List order (Filter: ?status=...)"),
            _Endpoint("GET", "/orders/{id}", "Detail order berdasarkan ID"),
            _Endpoint("PUT", "/orders/{id}/status", "Update status order"),
          ]),

          // 4. User Approval Service
          _buildServiceSection("User Approval Service", Icons.verified_user, [
            _Endpoint(
              "GET",
              "/users?status=menunggu_approval",
              "List user pending",
            ),
            _Endpoint(
              "PATCH",
              "/users/{id}/status",
              "Approve user (status: approved)",
            ),
            _Endpoint(
              "PATCH",
              "/users/{id}/status",
              "Reject user (status: rejected)",
            ),
          ]),

          // 5. Jadwal Sholat Service
          _buildServiceSection("Jadwal Sholat Service", Icons.mosque, [
            _Endpoint(
              "GET",
              "/jadwal/{idLokasi}/{datePath}",
              "Mengambil jadwal sholat eksternal",
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildServiceSection(
    String title,
    IconData icon,
    List<_Endpoint> endpoints,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: endpoints.map((e) => _buildEndpointItem(e)).toList(),
      ),
    );
  }

  Widget _buildEndpointItem(_Endpoint endpoint) {
    Color methodColor;
    switch (endpoint.method) {
      case "GET":
        methodColor = Colors.blue;
        break;
      case "POST":
        methodColor = Colors.green;
        break;
      case "PUT":
      case "PATCH":
        methodColor = Colors.orange;
        break;
      case "DELETE":
        methodColor = Colors.red;
        break;
      default:
        methodColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: methodColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: methodColor),
            ),
            child: Text(
              endpoint.method,
              style: TextStyle(
                color: methodColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              endpoint.path,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(endpoint.description),
      ),
    );
  }
}

// Model sederhana untuk endpoint
class _Endpoint {
  final String method;
  final String path;
  final String description;

  _Endpoint(this.method, this.path, this.description);
}
