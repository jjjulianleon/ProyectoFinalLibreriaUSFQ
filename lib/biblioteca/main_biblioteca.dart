import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/about/screens/about_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/chatbot/screens/chatbot_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/home/screens/home_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/members/screens/members_screen.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/auth_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/presentacion/login_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/books/screens/google_books_screen.dart';

void initBibliotecaApp() {
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica si el usuario está autenticado
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca USFQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 41, 82, 218)),
        useMaterial3: true,
      ),
      // Si el usuario está autenticado, muestra MyHomePage, de lo contrario muestra LoginScreen
      home: authProvider.isLoggedIn ? const MyHomePage() : const LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  
  // Guardamos las pantallas en una lista para poder acceder a ellas según el índice seleccionado
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    GoogleBooksScreen(), // Cambiamos BooksScreen por GoogleBooksScreen
    MembersScreen(),
    chatbotScreen(), // Corregido a CamelCase para seguir convenciones de Flutter
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Cierra el drawer
  }

  // Método para cerrar sesión y volver a la pantalla de login
  void _cerrarSesion() {
    Provider.of<AuthProvider>(context, listen: false).cerrarSesion();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Libreria USFQ',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          // Agregamos un botón de cierre de sesión en la barra superior
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blue),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 33, 235),
              ),
              accountName: Text(
                'Libreria USFQ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              accountEmail: Text(
                'Biblioteca pública',
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/library.png'),
              ),
            ),
            // Muestra la información del usuario autenticado
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ListTile(
                  leading: const CircleAvatar(backgroundImage: AssetImage('assets/photo.png')),
                  title: Text(
                    authProvider.currentUserName ?? 'Usuario',
                    style: const TextStyle(fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Administrador',
                    style: TextStyle(fontSize: 13),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Inicio'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Libros'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Miembros'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Chatbot'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Acerca de'),
              onTap: () => _onItemTapped(4),
            ),
            const Divider(),
            // Botón de cierre de sesión en el drawer
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}