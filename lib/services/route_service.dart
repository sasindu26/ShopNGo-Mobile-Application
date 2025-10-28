import 'package:flutter/material.dart';
import '/screens/login_screen.dart';
import '/screens/signup_screen.dart';
import '../screens/buyer/home_screen.dart';
import '../screens/buyer/profile_screen.dart';
import '../screens/buyer/categories_screen.dart';
import '/screens/seller/add_item_screen.dart';
import '/screens/seller/home_screen.dart';
import '/screens/seller/seller_items_screen.dart';
import '/screens/buyer/item_detail_screen.dart';
import '../screens/buyer/category_items_screen.dart';
import '../screens/buyer/wishlist_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '/screens/seller/add_item_screen.dart';
import '/screens/seller/manage_order_screen.dart';



class AppRoutes {
  static const String login = '/login';
  static const String register = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String category = '/category';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String sellerhome = '/sellerhome';
  static const String selleradditem = '/selleradditem';
  static const String selleritems = '/selleritems';
  static const String itemDetail = '/itemDetail';
  static const String categoryItems = '/categoryItems';
  static const String additem = '/addItem';
  static const String manageOrder = '/manageOrder';

  
 

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    register: (context) => SignUpScreen(),
    home: (context) => HomeScreen(),
    profile: (context) => ProfileScreen(),
    category: (context) => CategoriesScreen(),
    wishlist: (context) => WishlistScreen(),
    cart: (context) => CartScreen(),
    sellerhome: (context) => SellerHomePage(),
    selleradditem: (context) => AddItemScreen(),
    selleritems: (context) => SellerItemsScreen(),
    categoryItems: (context) => CategoryItemsScreen(category: ''),
    additem: (context) => AddItemScreen(),
    manageOrder: (context) => SellerOrdersScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == itemDetail) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: args['item']),
      );
    }
    return MaterialPageRoute(builder: routes[settings.name]!);
  }
}
