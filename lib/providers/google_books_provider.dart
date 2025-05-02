import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/models/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleBooksProvider with ChangeNotifier {
  List<Book1> _books = [];
  List<Book1> _savedBooks = [];
  // Mapa que almacena las valoraciones personalizadas por id de libro
  Map<String, double> _bookRatings = {};
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  
  List<Book1> get books => _books;
  List<Book1> get savedBooks => _savedBooks;
  Map<String, double> get bookRatings => _bookRatings;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  GoogleBooksProvider() {
    _loadSavedBooks();
    _loadBookRatings();
  }

  // Cargar libros guardados desde SharedPreferences
  Future<void> _loadSavedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBooksJson = prefs.getStringList('saved_books') ?? [];
      
      _savedBooks = savedBooksJson
          .map((json) => Book1.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar los libros guardados: $e');
    }
  }
  
  // Cargar valoraciones guardadas desde SharedPreferences
  Future<void> _loadBookRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = prefs.getString('book_ratings');
      
      if (ratingsJson != null) {
        final Map<String, dynamic> decodedMap = jsonDecode(ratingsJson);
        _bookRatings = decodedMap.map((key, value) => 
          MapEntry(key, (value is int) ? value.toDouble() : value));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar las valoraciones: $e');
    }
  }

  // Guardar libros en SharedPreferences
  Future<void> _saveBooksToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBooksJson = _savedBooks
          .map((book) => jsonEncode(book.toJson()))
          .toList();
      
      await prefs.setStringList('saved_books', savedBooksJson);
    } catch (e) {
      debugPrint('Error al guardar los libros: $e');
    }
  }
  
  // Guardar valoraciones en SharedPreferences
  Future<void> _saveRatingsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = jsonEncode(_bookRatings);
      
      await prefs.setString('book_ratings', ratingsJson);
    } catch (e) {
      debugPrint('Error al guardar las valoraciones: $e');
    }
  }

  // Agregar un libro a la biblioteca
  void addBookToLibrary(Book1 book) {
    if (!isBookInLibrary(book.id ?? '')) {
      _savedBooks.add(book);
      // Inicializamos la valoración con la que viene del libro o con 0
      if (!_bookRatings.containsKey(book.id)) {
        _bookRatings[book.id ?? ''] = book.valoracion > 0 ? book.valoracion : 0.0;
      }
      _saveBooksToPrefs();
      _saveRatingsToPrefs();
      notifyListeners();
    }
  }

  // Eliminar un libro de la biblioteca
  void removeBookFromLibrary(String bookId) {
    _savedBooks.removeWhere((book) => book.id == bookId);
    // Opcionalmente, podemos eliminar también la valoración
    // _bookRatings.remove(bookId); // Descomenta si quieres eliminar la valoración al eliminar el libro
    _saveBooksToPrefs();
    _saveRatingsToPrefs();
    notifyListeners();
  }

  // Verificar si un libro está en la biblioteca
  bool isBookInLibrary(String bookId) {
    return _savedBooks.any((book) => book.id == bookId);
  }
  
  // Actualizar la valoración de un libro
  void updateBookRating(String bookId, double rating) {
    _bookRatings[bookId] = rating;
    _saveRatingsToPrefs();
    notifyListeners();
  }
  
  // Obtener la valoración de un libro
  double getBookRating(String bookId) {
    return _bookRatings[bookId] ?? 0.0;
  }

  // Buscar libros en la API de Google Books
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&maxResults=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          _books = _parseBooks(data['items']);
        } else {
          _books = [];
        }
      } else {
        _error = 'Error al buscar libros. Código de estado: ${response.statusCode}';
        _books = [];
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar resultados de búsqueda
  void clearSearch() {
    _books = [];
    _searchQuery = '';
    _error = '';
    notifyListeners();
  }

  // Obtener detalles de un libro específico
  Future<Book1> getBookDetails(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes/$bookId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseBook(data);
      } else {
        throw Exception('Error al obtener detalles del libro. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Parsear un libro de la respuesta JSON
  Book1 _parseBook(Map<String, dynamic> bookData) {
    final volumeInfo = bookData['volumeInfo'] ?? {};
    
    return Book1(
      id: bookData['id'] ?? '',
      titulo: volumeInfo['title'] ?? 'Sin título',
      autor: _getAuthors(volumeInfo),
      editorial: volumeInfo['publisher'] ?? 'Desconocido',
      fechaPublicacion: volumeInfo['publishedDate'] ?? 'Desconocida',
      descripcion: volumeInfo['description'] ?? 'Sin descripción',
      portadaUrl: _getBookCover(volumeInfo),
      valoracion: volumeInfo['averageRating']?.toDouble() ?? 0.0,
      isbn: _getISBN(volumeInfo),
      paginas: volumeInfo['pageCount']?.toString() ?? 'Desconocido',
    );
  }

  // Parsear una lista de libros
  List<Book1> _parseBooks(List<dynamic> items) {
    return items.map((item) => _parseBook(item)).toList();
  }

  // Obtener autores de un libro
  String _getAuthors(Map<String, dynamic> volumeInfo) {
    if (volumeInfo['authors'] == null) return 'Autor desconocido';
    return (volumeInfo['authors'] as List).join(', ');
  }

  // Obtener URL de la portada del libro
  String _getBookCover(Map<String, dynamic> volumeInfo) {
    if (volumeInfo['imageLinks'] == null) {
      return 'https://via.placeholder.com/128x192?text=Sin+Imagen';
    }
    
    // Preferimos la imagen de thumbnail, pero si no está disponible usamos smallThumbnail
    return volumeInfo['imageLinks']['thumbnail'] ?? 
           volumeInfo['imageLinks']['smallThumbnail'] ?? 
           'https://via.placeholder.com/128x192?text=Sin+Imagen';
  }
  
  // Obtener ISBN de un libro
  String _getISBN(Map<String, dynamic> volumeInfo) {
    if (volumeInfo['industryIdentifiers'] == null) return 'Sin ISBN';
    
    final identifiers = volumeInfo['industryIdentifiers'] as List;
    for (var identifier in identifiers) {
      if (identifier['type'] == 'ISBN_13') {
        return identifier['identifier'];
      }
    }
    
    // Si no hay ISBN_13, intentamos con ISBN_10
    for (var identifier in identifiers) {
      if (identifier['type'] == 'ISBN_10') {
        return identifier['identifier'];
      }
    }
    
    return 'Sin ISBN';
  }
}