import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get cart items stream for the current user
  Stream<List<Map<String, dynamic>>> getCartStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('cart')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // Update cart item quantity
  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docId = '${user.uid}_$itemId';
    await _firestore.collection('cart').doc(docId).update({'quantity': newQuantity});
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docId = '${user.uid}_$itemId';
    await _firestore.collection('cart').doc(docId).delete();
  }

  // Get wishlist items stream for the current user
  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty(); // Return empty stream if not logged in
    }

    return _firestore
        .collection('wishlist')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = '${user.uid}_$itemId';
    await _firestore.collection('wishlist').doc(docId).delete();
  }
}