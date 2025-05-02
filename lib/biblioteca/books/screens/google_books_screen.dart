import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/google_books_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/models/book_model.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/screens/book_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async' as async;

class GoogleBooksScreen extends StatefulWidget {
  const GoogleBooksScreen({super.key});

  @override
  State<GoogleBooksScreen> createState() => _GoogleBooksScreenState();
}

class _GoogleBooksScreenState extends State<GoogleBooksScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Aplicar debounce a la búsqueda
    _searchController.addListener(_debounceSearch);
  }
  
  // Variables para el debounce
  Timer? _debounceTimer;
  
  void _debounceSearch() {
    // Cancelar el timer anterior si existe
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    
    // Crear un nuevo timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<GoogleBooksProvider>(context, listen: false);
      provider.searchBooks(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Books'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: 'Explorar',
            ),
            Tab(
              icon: Icon(Icons.book),
              text: 'Biblioteca',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExplorarTab(),
          _buildBibliotecaTab(),
        ],
      ),
    );
  }
  
  Widget _buildExplorarTab() {
    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar libros en Google Books',
              hintText: 'Ingrese título, autor o palabras clave...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<GoogleBooksProvider>(context, listen: false).clearSearch();
                },
              ),
            ),
          ),
        ),
        
        // Resultados de la búsqueda
        Expanded(
          child: Consumer<GoogleBooksProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.error.isNotEmpty) {
                return Center(
                  child: Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              
              if (provider.books.isEmpty) {
                if (provider.searchQuery.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Busque libros por título, autor o palabras clave',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados para "${provider.searchQuery}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              
              return ListView.builder(
                itemCount: provider.books.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final book = provider.books[index];
                  return _buildBookCard(book, context, true);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildBibliotecaTab() {
    return Consumer<GoogleBooksProvider>(
      builder: (context, provider, child) {
        if (provider.savedBooks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes libros en tu biblioteca',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Explora y agrega libros a tu biblioteca',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: provider.savedBooks.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            final book = provider.savedBooks[index];
            return _buildBookCard(book, context, false);
          },
        );
      },
    );
  }
  
  Widget _buildBookCard(Book1 book, BuildContext context, bool isExploreTab) {
    final provider = Provider.of<GoogleBooksProvider>(context, listen: false);
    final bool isInLibrary = provider.isBookInLibrary(book.id ?? '');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () async {
          // Al hacer tap, obtener más detalles del libro
          try {
            if (book.id != null) {
              final detailedBook = await provider.getBookDetails(book.id!);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(book1: detailedBook),
                  ),
                );
              }
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al cargar los detalles del libro: $e')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del libro
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: book.portadaUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              
              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.titulo,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Autor: ${book.autor}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: isInLibrary 
                              ? provider.getBookRating(book.id ?? '') 
                              : book.valoracion,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16.0,
                          // Solo permitir interacción si el libro está en la biblioteca o estamos en la pestaña biblioteca
                          ignoreGestures: !(isInLibrary || !isExploreTab),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            // Si el libro no está en la biblioteca, lo añadimos primero
                            if (!isInLibrary && isExploreTab) {
                              provider.addBookToLibrary(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Libro añadido a tu biblioteca')),
                              );
                            }
                            // Actualizamos la valoración
                            provider.updateBookRating(book.id ?? '', rating);
                          },
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          isInLibrary 
                              ? '(${provider.getBookRating(book.id ?? '').toStringAsFixed(1)})'
                              : book.valoracion > 0 
                                  ? '(${book.valoracion.toStringAsFixed(1)})' 
                                  : '(Sin calificar)',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      book.descripcion,
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Botón para agregar/quitar de la biblioteca
              if (isExploreTab)
                IconButton(
                  icon: Icon(
                    isInLibrary ? Icons.bookmark : Icons.bookmark_border,
                    color: isInLibrary ? Colors.blue : null,
                  ),
                  onPressed: () {
                    if (isInLibrary) {
                      provider.removeBookFromLibrary(book.id ?? '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Libro eliminado de tu biblioteca')),
                      );
                    } else {
                      provider.addBookToLibrary(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Libro añadido a tu biblioteca')),
                      );
                    }
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    provider.removeBookFromLibrary(book.id ?? '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Libro eliminado de tu biblioteca')),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Implementación adecuada de Timer para el debounce
class Timer {
  final Duration duration;
  final Function() callback;
  async.Timer? _timer;

  Timer(this.duration, this.callback) {
    _timer = async.Timer(duration, callback);
  }

  void cancel() {
    _timer?.cancel();
  }

  bool get isActive => _timer != null && _timer!.isActive;
}