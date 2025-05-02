import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/models/book_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatefulWidget {
  final Book1 book1;

  const BookDetailScreen({super.key, required this.book1});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book1 _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Libro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada y valoración
              Center(
                child: Column(
                  children: [
                    // Portada del libro
                    Hero(
                      tag: 'book_image_${_book.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: _book.portadaUrl,
                          height: 200,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            width: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 80),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Sistema de valoración
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating: _book.valoracion,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _book = _book.copyWith(valoracion: rating);
                            });
                          },
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '(${_book.valoracion.toStringAsFixed(1)})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Título y autor
              Text(
                _book.titulo,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Autor: ${_book.autor}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Detalles del libro
              _buildDetailItem('Categoría', _book.categoria ?? 'No disponible'),
              _buildDetailItem('Editorial', _book.editorial ?? 'No disponible'),
              _buildDetailItem('Fecha de publicación', _book.fechaPublicacion ?? 'No disponible'),
              _buildDetailItem('Páginas', _book.paginas ?? 'No disponible'),
              const SizedBox(height: 24.0),
              
              // Descripción
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _book.descripcion,
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 32.0),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddToLibraryDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar a Biblioteca'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _launchGoogleBooksUrl(_book.id);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ver en Google Books'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchGoogleBooksUrl(String? bookId) async {
    if (bookId == null) return;
    
    final url = Uri.parse('https://books.google.com/books?id=$bookId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }
  
  void _showAddToLibraryDialog(BuildContext context) {
    String selectedStatus = 'Por leer'; // Estado inicial
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar a Biblioteca'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona el estado de lectura:'),
            const SizedBox(height: 16),
            
            // Opciones de estado
            _buildStatusOption(context, 'Por leer', selectedStatus == 'Por leer', (isSelected) {
              if (isSelected) {
                selectedStatus = 'Por leer';
                Navigator.pop(context);
                _showAddToLibraryDialog(context);
              }
            }),
            
            _buildStatusOption(context, 'Leyendo', selectedStatus == 'Leyendo', (isSelected) {
              if (isSelected) {
                selectedStatus = 'Leyendo';
                Navigator.pop(context);
                _showAddToLibraryDialog(context);
              }
            }),
            
            _buildStatusOption(context, 'Leído', selectedStatus == 'Leído', (isSelected) {
              if (isSelected) {
                selectedStatus = 'Leído';
                Navigator.pop(context);
                _showAddToLibraryDialog(context);
              }
            }),
            
            _buildStatusOption(context, 'Abandonado', selectedStatus == 'Abandonado', (isSelected) {
              if (isSelected) {
                selectedStatus = 'Abandonado';
                Navigator.pop(context);
                _showAddToLibraryDialog(context);
              }
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para guardar el libro en la biblioteca con el estado seleccionado
              _saveBookToLibrary(selectedStatus);
              Navigator.pop(context);
              
              // Mostrar confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Libro agregado como "$selectedStatus"'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusOption(BuildContext context, String status, bool isSelected, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          Text(
            status,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  void _saveBookToLibrary(String status) {
    // Implementación para guardar el libro en la base de datos local
    // Esta función simularía la acción de guardar el libro con el estado seleccionado
    
    // Ejemplo de implementación:
    // final bookRepository = BookRepository();
    // final libraryBook = LibraryBook(
    //   bookId: _book.id,
    //   title: _book.titulo,
    //   author: _book.autor,
    //   coverUrl: _book.portadaUrl,
    //   status: status,
    //   addedDate: DateTime.now(),
    // );
    // bookRepository.addBookToLibrary(libraryBook);
    
    print('Guardando libro "${_book.titulo}" con estado: $status');
  }
}