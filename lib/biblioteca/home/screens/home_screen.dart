import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/about/screens/about_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/screens/google_books_screen.dart' as googleBooks;
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/chatbot/screens/chatbot_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/members/screens/members_screen.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del usuario autenticado
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUserName ?? 'Usuario';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 52, 114, 220), Color.fromARGB(255, 52, 114, 220)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: 'library_logo',
                    child: Image.asset('assets/library.png', width: 200, height: 200),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido $userName',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore nuestra colección de libros y únase a nuestra comunidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        icon: Icons.book,
                        title: 'Explorar libros',
                        onTap: () => _navigateTo(context, const googleBooks.GoogleBooksScreen()),
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Gestionar miembros',
                        onTap: () => _navigateTo(context, const MembersScreen()),
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat,
                        title: 'Asistencia Chatbot',
                        onTap: () => _navigateTo(context, const chatbotScreen()), // Corregido a CamelCase
                      ),
                      _buildFeatureCard(
                        icon: Icons.info,
                        title: 'Acerca de',
                        onTap: () => _navigateTo(context, const AboutScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _launchTelegram,
                    child: const Text.rich(
                      TextSpan(
                        text: 'Únete a nuestro ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'canal de Telegram',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' para más contenido'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Añadimos un botón para cerrar sesión en la pantalla principal
                  ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).cerrarSesion();
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función reusable para navegación
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Función para lanzar Telegram
  Future<void> _launchTelegram() async {
    final uri = Uri.parse('https://t.me/BibliotecaSecretaATRPBot');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(
          Uri.parse('https://t.me/BibliotecaSecretaATRPBot'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error al abrir el enlace: $e');
    }
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Color.fromARGB(255, 52, 114, 220)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}