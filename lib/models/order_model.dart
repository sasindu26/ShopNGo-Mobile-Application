import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id; // Document ID
  final String userId;
  final String itemId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final double total;
  final String status;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? 'Unnamed Item',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      quantity: (data['quantity'] as int?) ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemId': itemId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'total': total,
      'status': status,
      'createdAt': createdAt,
    };
  }
}