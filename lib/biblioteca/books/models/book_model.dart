class Book1 {
  final String? id;
  final String titulo;
  final String autor;
  final String portadaUrl;
  final String descripcion;
  double valoracion;
  final String? categoria;
  final String? editorial;
  final String? fechaPublicacion;
  final String? isbn;
  final String? paginas;
  final bool? disponible;
  final int? cantidadCopias;

  static var book1;
  
  Book1({
    this.id,
    required this.titulo,
    required this.autor,
    required this.portadaUrl,
    required this.descripcion,
    this.valoracion = 0.0,
    this.categoria,
    this.editorial,
    this.fechaPublicacion,
    this.isbn,
    this.paginas,
    this.disponible = true,
    this.cantidadCopias = 1,
  });

  // Constructor desde JSON de la base de datos local
  factory Book1.fromJson(Map<String, dynamic> json) {
    return Book1(
      id: json['id'],
      titulo: json['titulo'],
      autor: json['autor'],
      portadaUrl: json['portadaUrl'],
      descripcion: json['descripcion'],
      valoracion: json['valoracion']?.toDouble() ?? 0.0,
      categoria: json['categoria'],
      editorial: json['editorial'],
      fechaPublicacion: json['fechaPublicacion'],
      isbn: json['isbn'],
      paginas: json['paginas'],
      disponible: json['disponible'] == 1,
      cantidadCopias: json['cantidadCopias'] ?? 1,
    );
  }
// Constructor para crear un libro desde Google Books API
  factory Book1.fromGoogleBooksApi(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    
    // Extracción de autores
    List<dynamic> authors = volumeInfo['authors'] ?? [];
    String author = authors.isNotEmpty ? authors.join(', ') : 'Desconocido';
    
    // Extracción de categorías
    List<dynamic> categories = volumeInfo['categories'] ?? [];
    String? category = categories.isNotEmpty ? categories.first : null;
    
    // Extracción de portada
    String thumbnailUrl = 'https://via.placeholder.com/150';
    if (volumeInfo['imageLinks'] != null) {
      thumbnailUrl = volumeInfo['imageLinks']['thumbnail'] ?? 
                    volumeInfo['imageLinks']['smallThumbnail'] ?? 
                    'https://via.placeholder.com/150';
    }
    
    // Extracción de ID
    String id = json['id'] ?? '';
    
    return Book1(
      id: id,
      titulo: volumeInfo['title'] ?? 'Sin título',
      autor: author,
      descripcion: volumeInfo['description'] ?? 'Sin descripción disponible',
      portadaUrl: thumbnailUrl,
      categoria: category,
      editorial: volumeInfo['publisher'],
      fechaPublicacion: volumeInfo['publishedDate'],
      paginas: volumeInfo['pageCount']?.toString(),
    );
  }
  
  // Convertir a JSON para la base de datos local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'portadaUrl': portadaUrl,
      'descripcion': descripcion,
      'valoracion': valoracion,
      'categoria': categoria,
      'editorial': editorial,
      'fechaPublicacion': fechaPublicacion,
      'isbn': isbn,
      'paginas': paginas,
      'disponible': disponible == true ? 1 : 0,
      'cantidadCopias': cantidadCopias,
    };
  }

  // Crear una copia del libro con nuevos valores
  Book1 copyWith({
    String? id,
    String? titulo,
    String? autor,
    String? portadaUrl,
    String? descripcion,
    double? valoracion,
    String? categoria,
    String? editorial,
    String? fechaPublicacion,
    String? isbn,
    String? paginas,
    bool? disponible,
    int? cantidadCopias,
  }) {
    return Book1(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      descripcion: descripcion ?? this.descripcion,
      valoracion: valoracion ?? this.valoracion,
      categoria: categoria ?? this.categoria,
      editorial: editorial ?? this.editorial,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      isbn: isbn ?? this.isbn,
      paginas: paginas ?? this.paginas,
      disponible: disponible ?? this.disponible,
      cantidadCopias: cantidadCopias ?? this.cantidadCopias,
    );
  }
}