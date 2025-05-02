import 'package:ProyectoFinalLibreriaUSFQ/dominio/entidades/usuario.dart';

class UsuarioModel extends Usuario {
  UsuarioModel({
    required super.id, 
    required super.nombre, 
    required super.email,
    required super.contrasena, // Añadido al constructor
  });

  //Convierte un Map en un objeto UsuarioModel (utilizado en la pagina_principal).
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      contrasena: map['contrasena'], // Añadido para recuperar contraseña
    );
  }
  
  //Convierte un objeto UsuarioModel a un Map para insertarlo o actualizarlo en la base de datos.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena, // Añadido para guardar contraseña
    };

    // Solo agrega 'id' si es diferente de 0 o no nulo (este numero es creado por la base de datos para cada usuario)
    if (id != 0) { 
      map['id'] = id;
    }

    return map;
  } 
}