import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Acerca de la Biblioteca',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 62, 100, 215),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/library.png',
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Esta aplicación de gestión de biblioteca fue creada para facilitar la gestión de libros y miembros con un chatbot incluido.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      const ListTile(
                        leading: Icon(Icons.book, color: Color.fromARGB(255, 62, 100, 215)),
                        title: Text(
                          'Gestión de libros',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Agregue y elimine libros a su biblioteca personal.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const ListTile(
                        leading: Icon(Icons.people, color: Color.fromARGB(255, 62, 100, 215)),
                        title: Text(
                          'Gestión de miembros',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Gestione los miembros que pueden acceder a la aplicación.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const ListTile(
                        leading: Icon(Icons.chat, color: Color.fromARGB(255, 62, 100, 215)),
                        title: Text(
                          'Chatbot inteligente',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Utilice nuestro chatbot para obtener recomendaciones de libros y ayuda rápidamente.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        'Ventajas de nuestra biblioteca',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 62, 100, 215),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Acceso a una amplia colección de libros con interfaz de usuario intuitiva.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
