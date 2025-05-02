import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/models/book_model.dart';

class BookCard extends StatelessWidget {
  final Book1 book;
  final VoidCallback onTap;

  const BookCard({
    Key? key,
    required this.book,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada del libro
              Hero(
                tag: 'book_image_${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: book.portadaUrl,
                    height: 100,
                    width: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 100,
                      width: 70,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.autor,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (book.categoria != null)
                      Text(
                        book.categoria!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}