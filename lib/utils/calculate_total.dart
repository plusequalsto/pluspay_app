import 'package:pluspay/models/products.dart';

double calculateTotal(Map<String, int> cart, List<Products> products,
    double vatRate, double discountRate) {
  double subtotal = 0;

  // Calculate subtotal
  for (var entry in cart.entries) {
    final sku = entry.key;
    final quantity = entry.value;

    // Fetch the product by SKU
    final product = products.firstWhere(
      (product) => product.sku == sku,
      orElse: () => Products(
          sku: '',
          name: '',
          description: '',
          price: 0,
          currency: '',
          category: '',
          stock: 0,
          tags: []), // Create a dummy product
    );

    subtotal += product.price * quantity; // Accumulate subtotal
  }

  // Calculate VAT and total
  double vat = subtotal * vatRate;
  double discount = subtotal * discountRate;
  double total = subtotal + vat - discount;

  return total;
}
