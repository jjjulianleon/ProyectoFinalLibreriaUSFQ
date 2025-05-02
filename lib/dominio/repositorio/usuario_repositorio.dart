import 'package:ProyectoFinalLibreriaUSFQ/data/db/data_base.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
//Esta clase implementa el Patrón Repositorio, 
//lo que significa que actúa como intermediario entre 
//la lógica de la aplicación y la base de datos.

class UsuarioRepositorio {
  final DataBaseSqlite dbb = DataBaseSqlite();

  // Insertar un usuario
  Future<void> insertarUsuario(UsuarioModel usuario) async {
    final db = await dbb.database; //Abre o obtiene la conexión a la base de datos usando dbb (es una instancia de Database).
    await db.insert('usuarios', usuario.toMap()); //inserta un nuevo registro en la tabla usuarios, convierte el objeto UsuarioModel a un Map para insertarlo en la base de datos.
  }

//Método obtener Usuarios
  Future<List<UsuarioModel>> obtenerUsuarios() async {
    final db = await dbb.database; //instancia (abre conexion) a la basede datos
    final List<Map<String, dynamic>> maps = await db.query('usuarios'); //recupera (query) todos los registros de la tabla usuarios, la base de datos devuelve un map
    return List.generate(maps.length, (i) { // convierte la lista de mapas (maps) a una lista de objetos UsuarioModel.
      return UsuarioModel.fromMap(maps[i]);
    });
  }
//Método eliminar Usuario
  Future<void> eliminarUsuario(int id) async {
    final db = await dbb.database; //instancia (abrir conexion)
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]); //where: 'id = ?' es una condición que indica que solo se eliminará el usuario cuyo id coincida.
  }

  // Actualizar un usuario
  Future<void> actualizarUsuario(UsuarioModel usuario) async {
    final db = await dbb.database;
    await db.update(
       'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Verificar credenciales de inicio de sesión
  Future<UsuarioModel?> verificarCredenciales(String email, String contrasena) async {
    final db = await dbb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND contrasena = ?',
      whereArgs: [email, contrasena],
    );
    
    if (maps.isNotEmpty) {
      return UsuarioModel.fromMap(maps.first);
    }
    return null;
  }

  // Buscar usuario por email (útil para verificar si ya existe)
  Future<bool> existeUsuarioConEmail(String email) async {
    final db = await dbb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    return maps.isNotEmpty;
  }
}