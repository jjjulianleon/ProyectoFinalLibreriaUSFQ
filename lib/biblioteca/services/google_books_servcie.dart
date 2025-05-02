import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/models/book_model.dart';

class GoogleBooksService {
  static const String apiKey = 'AIzaSyDZ0y2fg-s0poA_w5bIYrmw7jpeHKjRpe8';
  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Buscar libros por consulta
  static Future<List<Book1>> searchBooks(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl?q=$query&key=$apiKey&maxResults=20'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>?;
      
      if (items == null) {
        return [];
      }

      return items.map((item) {
        final volumeInfo = item['volumeInfo'];
        final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
        
        return Book1(
          id: item['id'] ?? '',
          titulo: volumeInfo['title'] ?? 'Sin título',
          autor: _getAuthors(volumeInfo),
          portadaUrl: imageLinks?['thumbnail'] ?? 'https://via.placeholder.com/150',
          descripcion: volumeInfo['description'] ?? 'Sin descripción disponible',
          valoracion: volumeInfo['averageRating']?.toDouble() ?? 0.0,
        );
      }).toList();
    } else {
      throw Exception('Error al cargar libros: ${response.statusCode}');
    }
  }

  // Obtener detalles de un libro por ID
  static Future<Book1> getBookDetails(String bookId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$bookId?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final volumeInfo = data['volumeInfo'];
      final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
      
      return Book1(
        id: data['id'] ?? '',
        titulo: volumeInfo['title'] ?? 'Sin título',
        autor: _getAuthors(volumeInfo),
        portadaUrl: imageLinks?['thumbnail'] ?? 'https://via.placeholder.com/150',
        descripcion: volumeInfo['description'] ?? 'Sin descripción disponible',
        valoracion: volumeInfo['averageRating']?.toDouble() ?? 0.0,
        categoria: _getCategories(volumeInfo),
        fechaPublicacion: volumeInfo['publishedDate'] ?? '',
        editorial: volumeInfo['publisher'] ?? 'Editorial desconocida',
        paginas: volumeInfo['pageCount']?.toString() ?? '0',
      );
    } else {
      throw Exception('Error al cargar detalles del libro: ${response.statusCode}');
    }
  }

  // Función auxiliar para obtener autores
  static String _getAuthors(Map<String, dynamic> volumeInfo) {
    final authors = volumeInfo['authors'] as List<dynamic>?;
    if (authors == null || authors.isEmpty) {
      return 'Autor desconocido';
    }
    return authors.join(', ');
  }
  
  // Función auxiliar para obtener categorías
  static String _getCategories(Map<String, dynamic> volumeInfo) {
    final categories = volumeInfo['categories'] as List<dynamic>?;
    if (categories == null || categories.isEmpty) {
      return 'General';
    }
    return categories.join(', ');
  }
}