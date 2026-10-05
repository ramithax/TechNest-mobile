import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get subtotal {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final currentQuantity = _items[existingIndex].quantity;
      final newQuantity = currentQuantity + quantity;

      _items[existingIndex].quantity = newQuantity > product.stockQuantity
          ? product.stockQuantity
          : newQuantity;
    } else {
      final safeQuantity = quantity > product.stockQuantity
          ? product.stockQuantity
          : quantity;

      _items.add(CartItem(product: product, quantity: safeQuantity));
    }

    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    final item = _items[index];

    if (item.quantity < item.product.stockQuantity) {
      item.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool containsProduct(int productId) {
    return _items.any((item) => item.product.id == productId);
  }
}
