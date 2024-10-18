import 'package:flutter/material.dart';

import 'Product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartModel with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> orderedItems = [];

  List<CartItem> get items => _items;

  void addProduct(Product product) {
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(product: product));
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void placeOrder() {
    orderedItems = List.from(items);
    clearCart(); // Xóa giỏ hàng
    notifyListeners();
  }

  double get totalPrice => _items.fold(0, (sum, current) => sum + current.product.sale_price * current.quantity);

  double get orderedTotalPrice {
    return orderedItems.fold(0, (sum, item) => sum + item.product.sale_price * item.quantity);
  }
}


