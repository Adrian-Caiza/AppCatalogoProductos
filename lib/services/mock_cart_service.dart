import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../models/cart_item.dart';

// Definimos excepciones personalizadas para manejar los errores en la UI
class SimulationException implements Exception {
  final String message;
  SimulationException(this.message);
}

class MockCartService extends ChangeNotifier {
  // Singleton
  static final MockCartService _instance = MockCartService._internal();
  factory MockCartService() => _instance;
  MockCartService._internal();

  final List<CartItem> _items = [];
  final Random _random = Random();

  // Getters públicos (Inmutables para fuera de la clase)
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  // Cálculos financieros
  Map<String, double> get totals {
    double subtotal = _items.fold(0, (sum, item) => sum + item.total);
    double discount = subtotal > 100 ? subtotal * 0.10 : 0.0;
    double subtotalAfterDiscount = subtotal - discount;
    double tax = subtotalAfterDiscount * 0.12;
    double total = subtotalAfterDiscount + tax;

    return {
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
    };
  }

  // --- MÉTODOS PÚBLICOS (Simulan Backend) ---

  Future<void> addToCart(Producto producto, {int cantidad = 1}) async {
    await _simulateNetworkDelay();
    _simulateRandomError(action: "agregar");

    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    
    if (index >= 0) {
      // Validar stock ficticio (10 unidades)
      if (_items[index].cantidad + cantidad > 10) {
        throw SimulationException("Stock insuficiente (Máx 10)");
      }
      _items[index].cantidad += cantidad;
    } else {
      if (cantidad > 10) throw SimulationException("Stock insuficiente");
      _items.add(CartItem(producto: producto, cantidad: cantidad));
    }
    
    notifyListeners(); // Notificar a la UI para redibujar
  }

  Future<void> removeFromCart(String productId) async {
    await _simulateNetworkDelay();
    _simulateRandomError();

    _items.removeWhere((item) => item.producto.id == productId);
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int change) async {
    // change puede ser +1 o -1
    await _simulateNetworkDelay(); // Pequeño delay para realismo
    
    final index = _items.indexWhere((item) => item.producto.id == productId);
    if (index == -1) return;

    final newQuantity = _items[index].cantidad + change;

    // Validaciones
    if (newQuantity < 1) return; // No permitir 0
    if (newQuantity > 10) throw SimulationException("Stock límite alcanzado (10)");

    _items[index].cantidad = newQuantity;
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    
    _items.clear();
    notifyListeners();
  }

  // --- SIMULACIÓN INTERNA ---

  Future<void> _simulateNetworkDelay() async {
    // Delay de 1 a 2 segundos
    final milliseconds = 1000 + _random.nextInt(1000);
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void _simulateRandomError({String action = ""}) {
    // 20% de probabilidad de error
    if (_random.nextDouble() < 0.20) {
      final errors = [
        "Error de conexión con el servidor",
        "El servicio no está disponible temporalmente",
        "Su sesión ha expirado",
      ];
      
      if (action == "agregar") {
        errors.add("Stock insuficiente en almacén remoto");
        errors.add("Producto no disponible");
      }

      throw SimulationException(errors[_random.nextInt(errors.length)]);
    }
  }
}