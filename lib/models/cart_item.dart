import 'producto.dart';

class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({
    required this.producto,
    this.cantidad = 1,
  });

  // Getters para cálculos rápidos
  double get total => producto.precio * cantidad;
}
