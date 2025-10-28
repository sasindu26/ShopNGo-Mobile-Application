import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id; // Unique ID for the item
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String sellerId; // Links to the seller (user ID)
  final String category; // New field for item category
  final Timestamp createdAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sellerId,
    required this.category, // Added to constructor
    required this.createdAt,
  });

  // Convert Firestore data to ItemModel
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      category: data['category'] ?? '', // Default value if missing
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert ItemModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'category': category, // Added to Firestore map
      'createdAt': createdAt,
    };
  }
}