import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Data pengembang aplikasi
  static const List<Map<String, String>> _developers = [
    {
      'name': 'Muhammad Ikhsan',
      'nim': '152022001',
      'photo': 'assets/images/ikhsan.jpg',
    },
    {
      'name': 'Muhammad Usri Yusron',
      'nim': '152022132',
      'photo': 'assets/images/yusron.jpg',
    },
    {
      'name': 'Muhammad Yazid',
      'nim': '152022192',
      'photo': 'assets/images/yazid.jpg',
    },
    {
      'name': 'Budi Amin',
      'nim': '152022213',
      'photo': 'assets/images/budi.jpg',
    },
    {
      'name': 'Ahmad Faoyan',
      'nim': '152024601',
      'photo': 'assets/images/faoyan.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tim Pengembang",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1565C0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          const Center(
            child: Column(
              children: [
                Icon(Icons.group, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'Sistem Admin Telor Gulung',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Dikembangkan oleh:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Developer Cards
          ..._developers.map((dev) => _buildDeveloperCard(dev)),

          const SizedBox(height: 24),

          // YouTube Demo Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                const youtubeUrl =
                    'https://www.youtube.com/watch?v=xhXOB7wXpp4';
                final uri = Uri.parse(youtubeUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak dapat membuka link YouTube'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.play_circle_fill, color: Colors.red),
              label: const Text(
                'Tonton Video Demo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 100), // Extra padding for bottom navbar
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(Map<String, String> developer) {
    String? photoPath = developer['photo'];
    bool hasPhoto = photoPath != null && photoPath.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar dengan foto atau placeholder
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: hasPhoto ? AssetImage(photoPath) : null,
              child: hasPhoto
                  ? null
                  : Icon(Icons.person, size: 32, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    developer['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NIM: ${developer['nim']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
