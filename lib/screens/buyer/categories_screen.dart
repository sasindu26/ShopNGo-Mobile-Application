import 'package:flutter/material.dart';
import 'package:shopngo/screens/buyer/category_items_screen.dart';
import 'package:shopngo/utils/constants.dart';
import '../../widgets/bottom_navigation_bar.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

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
    // List of categories with names and icons
    final List<Map<String, dynamic>> categories = [
      {'name': 'Electronics', 'icon': Icons.devices_other},
      {'name': 'Home', 'icon': Icons.home},
      {'name': 'Beauty', 'icon': Icons.spa},
      {'name': 'Sports', 'icon': Icons.sports_esports},
      {'name': 'Clothing', 'icon': Icons.checkroom},
      {'name': 'Books', 'icon': Icons.book},
      {'name': 'Toys', 'icon': Icons.toys},
      {'name': 'Others', 'icon': Icons.category},
    ];

    return Scaffold(
      appBar: AppBar(
           shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Text('Categories', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.darkBlue,
                iconTheme: const IconThemeData(color: Colors.white),
 // Updated to use AppColors
      ),
      backgroundColor: AppColors.backgroundColor, // Updated to use AppColors
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryItemsScreen(category: category['name']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    size: 50.0,
                    color: AppColors.mediumBlue, // Updated to use AppColors
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue, // Updated to use AppColors
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) => _navigateToPage(context, index),
      ),
    );
  }
}