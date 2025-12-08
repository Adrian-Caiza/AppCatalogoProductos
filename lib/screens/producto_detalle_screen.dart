import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/mock_cart_service.dart';
import 'cart_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  // Estado para controlar la carga del botón
  bool _isAdding = false;
  
  // Referencia segura al mensajero para evitar errores de contexto
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // Limpieza agresiva al salir para que no queden mensajes colgados
    _scaffoldMessenger.clearSnackBars();
    super.dispose();
  }

  // Lógica segura de "Agregar al Carrito"
  Future<void> _agregarAlCarrito() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);
    _scaffoldMessenger.clearSnackBars();

    // 1. Mensaje de "Procesando..."
    _scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Procesando...'),
        duration: Duration(milliseconds: 1000), 
        backgroundColor: Colors.black87,
      ),
    );

    final cartService = MockCartService();

    try {
      await cartService.addToCart(widget.producto);

      if (!mounted) return;

      // 2. Éxito: Limpiamos y mostramos confirmación
      _scaffoldMessenger.clearSnackBars();
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${widget.producto.nombre} agregado'),
          backgroundColor: Colors.blue, // Azul para combinar con el tema
          duration: const Duration(seconds: 2), // Duración corta (2s)
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: Colors.white,
            onPressed: () {
              if (mounted) {
                _scaffoldMessenger.clearSnackBars();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      _scaffoldMessenger.clearSnackBars();
      String msg = e is SimulationException ? e.message : "Error inesperado";
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos SingleChildScrollView como base principal, igual al diseño original
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER STACK (Imagen + Botones Flotantes) ---
            Stack(
              children: [
                // 1. Fondo de Imagen
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Hero(
                    tag: widget.producto.id,
                    child: Icon(
                      _getIcono(widget.producto.imagenUrl),
                      size: 150,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // 2. Botón Atrás
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // 3. Etiqueta Descuento
                Positioned(
                  top: 110,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '-20%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 4. Botón Favorito
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {},
                    ),
                  ),
                ),

                // 5. Botón "Agregar" (FAB) - Restaurado a su posición original en el Stack
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton.extended(
                    onPressed: _isAdding ? null : _agregarAlCarrito,
                    backgroundColor: Colors.blue,
                    // Cambiamos el icono a un loader si está procesando
                    icon: _isAdding 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.shopping_cart, color: Colors.white),
                    label: Text(
                      _isAdding ? "Espere..." : "Agregar", 
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                ),
              ],
            ),

            // --- CONTENIDO DEL PRODUCTO ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.producto.nombre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Categoría
                  Text(
                    widget.producto.categoria,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  Row(
                    children: [
                      Text(
                        '\$${widget.producto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '(Incluye IVA)',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Título Descripción
                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Texto Descripción
                  Text(
                    "${widget.producto.descripcion}. Este es un producto de excelente calidad diseñado para satisfacer tus necesidades tecnológicas.\nCuenta con garantía extendida y soporte técnico especializado.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- BOTÓN COMPRAR AHORA (Restaurado al final del scroll) ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                          // Lógica dummy de compra directa
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Funcionalidad de compra directa no implementada"))
                          );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Comprar Ahora",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para iconos
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