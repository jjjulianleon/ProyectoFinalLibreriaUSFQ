import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/dominio/repositorio/usuario_repositorio.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioRepositorio _usuarioRepositorio = UsuarioRepositorio();
  List<UsuarioModel> _usuarios = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<UsuarioModel> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor
  UsuarioProvider() {
    cargarUsuarios();
  }

  // Método para cargar usuarios
  Future<void> cargarUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarios = await _usuarioRepositorio.obtenerUsuarios();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar usuarios: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para agregar usuario
  Future<bool> agregarUsuario(String nombre, String email, String contrasena) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Verificar si ya existe un usuario con ese email
      final existeUsuario = await _usuarioRepositorio.existeUsuarioConEmail(email);

      if (existeUsuario) {
        _errorMessage = 'Ya existe un usuario con ese email';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear un nuevo usuario
      final nuevoUsuario = UsuarioModel(
        id: 0, // ID autogenerado
        nombre: nombre,
        email: email,
        contrasena: contrasena,
      );

      // Insertar el usuario en la base de datos
      await _usuarioRepositorio.insertarUsuario(nuevoUsuario);
      
      // Recargar la lista de usuarios
      await cargarUsuarios();
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar usuario: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para actualizar usuario
  Future<bool> actualizarUsuario(UsuarioModel usuario) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _usuarioRepositorio.actualizarUsuario(usuario);
      await cargarUsuarios();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar usuario: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para eliminar usuario
  Future<bool> eliminarUsuario(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _usuarioRepositorio.eliminarUsuario(id);
      await cargarUsuarios();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar usuario: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para limpiar mensajes de error
  void limpiarErrores() {
    _errorMessage = '';
    notifyListeners();
  }
}