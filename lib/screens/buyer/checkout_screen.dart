import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:shopngo/models/item_model.dart';
import 'package:shopngo/models/order_model.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFFFF2F2);
  static const Color lightBlue = Color(0xFFA9B5DF);
  static const Color mediumBlue = Color(0xFF7886C7);
  static const Color darkBlue = Color(0xFF2D336B);
}

class CheckoutScreen extends StatefulWidget {
  final ItemModel item;

  const CheckoutScreen({super.key, required this.item});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _quantity = 1;
  bool isLoading = false;

  Future<void> makePayment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to proceed with payment'), backgroundColor: Colors.redAccent),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      setState(() => isLoading = true);
      print('Item price: ${widget.item.price}');
      print('Quantity: $_quantity');
      final total = widget.item.price * _quantity;
      print('Total before conversion: $total');
      final amount = (total * 100).toInt();
      print('Amount sent to function: $amount');

      if (amount <= 0) {
        print('Invalid amount detected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total amount must be greater than 0'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      final callable = FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable('createPaymentIntent');
      final response = await callable.call(<String, dynamic>{
        'amount': amount,
        'currency': 'usd',
      });
      final clientSecret = response.data['clientSecret'];
      print('Client Secret: $clientSecret');

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ShopNGO',
          style: ThemeMode.light,
        ),
      );
      await stripe.Stripe.instance.presentPaymentSheet();

      final order = OrderModel(
        id: '',
        userId: user.uid,
        itemId: widget.item.id,
        name: widget.item.name,
        price: widget.item.price,
        imageUrl: widget.item.imageUrl,
        quantity: _quantity,
        total: total,
        status: 'paid',
        createdAt: Timestamp.now(),
      );
      await FirebaseFirestore.instance.collection('orders').add(order.toMap());

      // Show success message and reset quantity
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!'), backgroundColor: AppColors.mediumBlue),
      );
      
      // Reset the quantity to 1 instead of navigating away
      setState(() {
        _quantity = 1;
      });
    } catch (e) {
      print('Payment Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.item.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    widget.item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.item.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.image, size: 80, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: \$${widget.item.price.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Quantity: ', style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.remove, color: AppColors.darkBlue),
                                onPressed: _decrementQuantity,
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: AppColors.darkBlue),
                                onPressed: _incrementQuantity,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping:', style: TextStyle(fontSize: 16)),
                const Text('Free', style: TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator(color: AppColors.darkBlue)
                  : ElevatedButton(
                      onPressed: () => makePayment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: const Text('Buy Now', style: TextStyle(fontSize: 18)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}