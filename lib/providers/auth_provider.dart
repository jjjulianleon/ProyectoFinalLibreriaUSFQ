import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/dominio/repositorio/usuario_repositorio.dart';

class AuthProvider extends ChangeNotifier {
  final UsuarioRepositorio _usuarioRepository = UsuarioRepositorio();
  
  bool _isLoggedIn = false;
  int? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;

  // Método para iniciar sesión
  Future<bool> iniciarSesion(String email, String contrasena) async {
    try {
      // Validamos que los campos no estén vacíos
      if (email.isEmpty || contrasena.isEmpty) {
        return false;
      }

      // Obtenemos el usuario por email y contraseña
      final usuario = await _usuarioRepository.verificarCredenciales(
        email,
        contrasena,
      );

      if (usuario != null) {
        // Guardamos los datos del usuario
        _isLoggedIn = true;
        _currentUserId = usuario.id;
        _currentUserName = usuario.nombre;
        _currentUserEmail = usuario.email;
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      return false;
    }
  }

  // Método para cerrar sesión
  void cerrarSesion() {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    
    notifyListeners();
  }

  // Método para actualizar información del usuario cuando cambia en la base de datos
  void actualizarUsuarioActual(UsuarioModel usuario) {
    if (_isLoggedIn && _currentUserId == usuario.id) {
      _currentUserName = usuario.nombre;
      _currentUserEmail = usuario.email;
      notifyListeners();
    }
  }
}