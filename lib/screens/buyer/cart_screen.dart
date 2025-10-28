import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopngo/models/item_model.dart';
import 'package:shopngo/screens/buyer/checkout_screen.dart' as checkout;
import '/utils/app_colors.dart';
import '/widgets/bottom_navigation_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, bool> selectedItems = {}; // Tracks selected items by ID

  void _navigateToPage(BuildContext context, int index) {
    String routeName = '';
    if (index == 0) {
      routeName = '/home';
    } else if (index == 1) {
      routeName = '/category';
    } else if (index == 2) {
      routeName = '/wishlist';
    } else if (index == 3) {
      routeName = '/cart';
    }

    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

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
          title: const Text('Cart'),
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to view your cart.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Text('Cart'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final cartItems = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ItemModel(
              id: data['itemId'],
              name: data['name'],
              price: (data['price'] as num).toDouble(),
              imageUrl: data['imageUrl'],
              category: '', // Add if stored in cart
              description: '', // Add if stored in cart
              sellerId: data['sellerId'] ?? '',
              createdAt: data['createdAt'] ?? Timestamp.now(),
            );
          }).toList();

          // Initialize selection state for new items
          for (var item in cartItems) {
            selectedItems.putIfAbsent(item.id, () => false);
          }

          // Calculate total for selected items only
          final selectedTotal = cartItems
              .where((item) => selectedItems[item.id] == true)
              .fold(0.0, (sum, item) => sum + item.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedItems[item.id] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedItems[item.id] = value ?? false;
                              });
                            },
                            activeColor: AppColors.darkBlue,
                          ),
                          item.imageUrl.isNotEmpty
                              ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 50),
                        ],
                      ),
                      title: Text(item.name),
                      subtitle: Text('\Rs.${item.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('cart')
                              .doc('${user.uid}_${item.id}')
                              .delete();
                          setState(() {
                            selectedItems.remove(item.id); // Remove from selection
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \Rs.${selectedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final selected = cartItems.where((item) => selectedItems[item.id] == true).toList();
                        if (selected.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one item to checkout'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        // Navigate to CheckoutScreen with selected items
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => checkout.CheckoutScreen(
                              item: selected.length == 1
                                  ? selected[0]
                                  : ItemModel(
                                      id: 'multiple',
                                      name: 'Multiple Items',
                                      price: selectedTotal,
                                      imageUrl: '',
                                      category: '',
                                      description: '',
                                      sellerId: '',
                                      createdAt: Timestamp.now(),
                                    ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3,
        onItemTapped: (index) => _navigateToPage(context, index),
      ),
    );
  }
}