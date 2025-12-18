import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../service/order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _orderService.fetchOrders();

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'];

        setState(() {
          _orders = data.map((json) => OrderModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal load data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getToppingsText(OrderModel order) {
    List<String> toppings = [];
    if (order.balado) toppings.add('Balado');
    if (order.keju) toppings.add('Keju');
    if (order.pedas) toppings.add('Pedas');
    if (order.asin) toppings.add('Asin');
    if (order.barbeque) toppings.add('Barbeque');

    if (toppings.isEmpty) return 'Original (Tanpa Topping)';
    return toppings.join(', ');
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_antrian':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateStatusDialog(OrderModel order) {
    String selectedStatus = order.status;
    final List<String> statuses = [
      'menunggu_antrian',
      'diproses',
      'selesai',
      'dibatalkan',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update status untuk pesanan #${order.id}?'),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: statuses.contains(selectedStatus)
                        ? selectedStatus
                        : statuses.first,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: statuses.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => selectedStatus = newValue!);
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processUpdateStatus(order.id, selectedStatus);
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processUpdateStatus(int id, String newStatus) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengupdate status...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final response = await _orderService.updateOrderStatus(
        orderId: id,
        status: newStatus,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'kelola Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.blue,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Column(
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pesanan masuk',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tarik ke bawah untuk refresh',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.productName ??
                                                'Unknown Product',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Order #${order.id}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          order.status,
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order.status
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${order.total_barang} pcs'),
                                    const Spacer(),
                                    Text(
                                      'Total: Rp ${order.total_harga}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(_getToppingsText(order)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _showUpdateStatusDialog(order),
                                    icon: const Icon(Icons.edit_note),
                                    label: const Text('Update Status'),
                                  ),
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
