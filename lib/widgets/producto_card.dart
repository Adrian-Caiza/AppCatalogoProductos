import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../screens/producto_detalle_screen.dart';
import '../services/mock_cart_service.dart'; 

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({
    super.key,
    required this.producto,
  });

  // Método auxiliar para manejar la lógica de agregar
  Future<void> _agregarRapido(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final cartService = MockCartService();

    // Feedback inmediato
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Agregando...'),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await cartService.addToCart(producto);
      
      // Verificamos si el widget sigue montado (aunque en StatelessWidget es menos crítico, es buena práctica)
      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('${producto.nombre} agregado al carrito'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.hideCurrentSnackBar();
        String msg = e is SimulationException ? e.message : "Error inesperado";
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductoDetalleScreen(producto: producto),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Hero(
                      tag: producto.id,
                      child: Icon(
                        _getIcono(producto.imagenUrl),
                        size: 60,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                // Información
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          producto.descripcion,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${producto.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            // BOTÓN DE AGREGAR AL CARRITO (MODIFICADO)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _agregarRapido(context), // Llama a la función
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6), // Aumenté un poco el padding táctil
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Etiqueta NUEVO
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcono(String tipo) {
    switch (tipo) {
      case 'laptop': return Icons.laptop;
      case 'headphones': return Icons.headphones;
      case 'watch': return Icons.watch;
      case 'camera': return Icons.camera_alt;
      case 'keyboard': return Icons.keyboard;
      case 'mouse': return Icons.mouse;
      default: return Icons.shopping_bag;
    }
  }
}