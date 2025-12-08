import 'package:flutter/material.dart';
import '../services/mock_cart_service.dart';
import '../widgets/barra_navegacion.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final MockCartService _cartService = MockCartService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  // Método para mostrar el diálogo de confirmación
  Future<void> _confirmarVaciarCarrito() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe elegir una opción
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Deseas eliminar todos los productos de tu carrito?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Sí, vaciar carrito',
                style: TextStyle(color: Colors.red), // Rojo para indicar peligro
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _handleAsyncAction(() => _cartService.clearCart()); // Ejecuta la acción
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAsyncAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        String message = e is SimulationException ? e.message : "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _handleAsyncAction(action),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final totals = _cartService.totals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Carrito"),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              // AHORA LLAMAMOS AL DIÁLOGO EN LUGAR DE BORRAR DIRECTAMENTE
              onPressed: _isLoading 
                  ? null 
                  : () => _confirmarVaciarCarrito(),
            )
        ],
      ),
      body: Stack(
        children: [
          items.isEmpty
              ? const Center(child: Text("Tu carrito está vacío"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: Icon(Icons.shopping_bag, color: Colors.blue),
                            title: Text(item.producto.nombre),
                            subtitle: Text("\$${item.producto.precio} x ${item.cantidad}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: _isLoading 
                                    ? null 
                                    : () => _handleAsyncAction(() => _cartService.updateQuantity(item.producto.id, -1)),
                                ),
                                Text("${item.cantidad}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: _isLoading 
                                    ? null 
                                    : () => _handleAsyncAction(() => _cartService.updateQuantity(item.producto.id, 1)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: _isLoading 
                                    ? null 
                                    : () => _handleAsyncAction(() => _cartService.removeFromCart(item.producto.id)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    _buildResumenTotal(totals),
                  ],
                ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(
        indiceActual: 3,
        onTap: (index) {
             if (index == 0) Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildResumenTotal(Map<String, double> totals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, -5))],
      ),
      child: Column(
        children: [
          _rowResumen("Subtotal", totals['subtotal']!),
          if (totals['discount']! > 0)
            _rowResumen("Descuento (10%)", -totals['discount']!, isDiscount: true),
          _rowResumen("IVA (12%)", totals['tax']!),
          const Divider(),
          _rowResumen("TOTAL", totals['total']!, isTotal: true),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || _cartService.items.isEmpty ? null : () {
                 _handleAsyncAction(() => _cartService.clearCart());
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("¡Compra realizada con éxito!"))
                 );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text("Pagar Ahora"),
            ),
          )
        ],
      ),
    );
  }

  Widget _rowResumen(String label, double value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          )),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isDiscount ? Colors.green : (isTotal ? Colors.blue : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}