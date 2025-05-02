//clase usuario
class Usuario {
  //atributos
  final int id;
  final String nombre;
  final String email;
  final String contrasena; // Nuevo campo para la contraseña
  //constructor
  Usuario({
    required this.id, 
    required this.nombre, 
    required this.email,
    required this.contrasena, // Añadido al constructor
  });
}