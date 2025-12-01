import 'package:flutter/material.dart';
import '../models/producto.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Stack(
              children: [
                
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
                    tag: producto.id, 
                    child: Icon(
                      _getIcono(producto.imagenUrl),
                      size: 150,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                
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

                
                Positioned(
                  bottom: 20, 
                  right: 20,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${producto.nombre} agregado al carrito')),
                      );
                    },
                    backgroundColor: Colors.blue,
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text("Agregar", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  
                  Text(
                    producto.categoria,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  Row(
                    children: [
                      Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
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

                  
                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  
                  Text(
                    "${producto.descripcion}. Este es un producto de excelente calidad diseñado para satisfacer tus necesidades tecnológicas. Cuenta con garantía extendida y soporte técnico especializado.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
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