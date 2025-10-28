// lib/data/services/item_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/models/item_model.dart'; // Adjust path as per your structure

class ItemService {
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add an item to Firestore with an image
  Future<void> addItem({
    required String name,
    required double price,
    required String description,
    required String sellerId,
    required File imageFile, // Image file picked by the user
    required String category, // New field for item category
  }) async {
    try {
      // Upload image to Firebase Storage
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child('item_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Create ItemModel instance
      ItemModel item = ItemModel(
        id: '', // ID will be set by Firestore
        name: name,
        price: price,
        description: description,
        imageUrl: imageUrl,
        sellerId: sellerId,
        category: category, 
        createdAt: Timestamp.now(),
      );

      // Save to Firestore
      await _itemsCollection.add(item.toFirestore());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // Optional: Fetch all items (for listing later)
  Future<List<ItemModel>> getItems() async {
    try {
      QuerySnapshot snapshot = await _itemsCollection.get();
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }
}