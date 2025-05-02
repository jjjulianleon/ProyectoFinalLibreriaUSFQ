import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/google_books_provider.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/auth_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/usuario_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/presentacion/login_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/main_biblioteca.dart';

void main() {
  // Inicializamos la aplicación de biblioteca (si es necesario)
  initBibliotecaApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => GoogleBooksProvider()),
        // Aquí puedes agregar otros providers que necesites
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca USFQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 41, 82, 218)),
        useMaterial3: true,
      ),
      // Definimos las rutas de la aplicación
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(),
      },
      // La ruta inicial es la pantalla de login
      initialRoute: '/',
    );
  }
}