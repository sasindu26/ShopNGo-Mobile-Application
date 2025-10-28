// lib/screens/seller/seller_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  // Color palette from SellerHomePage
  static const Color backgroundColor = Color(0xFFFFF2F2); // #FFF2F2
  static const Color lightAccent = Color(0xFFA9B5DF); // #A9B5DF
  static const Color mediumAccent = Color(0xFF7886C7); // #7886C7
  static const Color darkAccent = Color(0xFF2D336B); // #2D336B

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
           shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
          title: const Text('Manage Orders'),
          backgroundColor: darkAccent,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to view orders.')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
        appBar: AppBar(
           shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Text('Manage Orders'),
        backgroundColor: darkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', whereIn: ['paid', 'shipped', 'delivered']) // Show all relevant statuses
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: darkAccent));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          // Filter orders for this seller
          return FutureBuilder<List<DocumentSnapshot>>(
            future: _filterSellerOrders(snapshot.data!.docs, user.uid),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: darkAccent));
              }
              if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                return const Center(child: Text('No orders for your items.'));
              }

              final orders = futureSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final orderId = orders[index].id;
                  final status = order['status'] as String;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${orderId.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Item: ${order['name']}', style: const TextStyle(fontSize: 16)),
                          Text('Total: \$${order['total'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                          Text('Quantity: ${order['quantity']}', style: const TextStyle(fontSize: 16)),
                          Text(
                            'Status: ${status[0].toUpperCase()}${status.substring(1)}', // Capitalize status
                            style: TextStyle(
                              fontSize: 16,
                              color: status == 'paid'
                                  ? Colors.green
                                  : status == 'shipped'
                                      ? Colors.orange
                                      : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status == 'paid') // Show only if paid
                                ElevatedButton(
                                  onPressed: () => _updateOrderStatus(context, orderId, 'shipped'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mediumAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Mark as Shipped'),
                                ),
                              if (status == 'paid' || status == 'shipped') // Show for paid or shipped
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () => _updateOrderStatus(context, orderId, 'delivered'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Mark as Delivered'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Filter orders where itemId matches items owned by the seller
  Future<List<DocumentSnapshot>> _filterSellerOrders(List<DocumentSnapshot> orders, String sellerId) async {
    final sellerItems = await FirebaseFirestore.instance
        .collection('items')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final sellerItemIds = sellerItems.docs.map((doc) => doc.id).toSet();

    return orders.where((order) {
      final itemIds = (order['itemId'] as String).split(','); // Split comma-separated itemIds
      return itemIds.any((id) => sellerItemIds.contains(id));
    }).toList();
  }

  // Update order status
  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus!'),
          backgroundColor: mediumAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}