import 'package:sqflite/sqflite.dart'; //Proporciona funcionalidades para interactuar con bases de datos SQLite.
import 'package:path/path.dart';//Se utiliza para construir rutas de archivos de manera segura en diferentes plataformas.

class DataBaseSqlite {
  //Tipo static permite acceder a _instance sin crear una nueva instancia de DataBaseSqlite.
  static final DataBaseSqlite instancia = DataBaseSqlite._internal();
  static Database? basedatos;

//factory devuelve la única instancia de DataBaseSqlite, Si llamas varias veces a DataBaseSqlite(), obtendrás siempre la misma instancia
// factory -> patrón Singleton asegura que todas las operaciones de la base de datos usen la misma conexión.  
  factory DataBaseSqlite() {
    return instancia;
  }
//_internal() es un constructor privado (va de la mano con factory - patron singleton) que evita que otras clases creen instancias de DataBaseSqlite directamente.
  DataBaseSqlite._internal();
  
// Getter para Obtener la Base de Datos
  Future<Database> get database async {
    if (basedatos != null) return basedatos!;

    //Funcion para Abrir o Inicializar la Base de Datos:
    basedatos = await inicializarBDD();
    return basedatos!;
  }
  
//Abrir o Inicializar la Base de Datos:
  Future<Database> inicializarBDD() async {
    //join() combina esta ruta con el nombre del archivo (usuarios.db) para crear la ruta completa de la base de datos.
    String path = join(await getDatabasesPath(), 'usuarios.db'); //obtiene la ruta del directorio donde se almacenan las bases de datos en el dispositivo.
  // Guarda la base de datos en una ubicación accesible
//  String path = '/sdcard/usuarios.db';
    print('Ruta de la base de datos: $path');
    return await openDatabase( //abre la base de datos si ya existe o la crea si no existe.
      path, // Ruta donde se guardará la base de datos.
      version: 2, // Incrementar la versión para migrar la base de datos
      onCreate: (db, version) async {  //onCreate se ejecuta solo una vez cuando la base de datos se crea por primera vez
        //execute-> ejecuta una consulta SQL para crear la tabla usuarios si no existe.
        await db.execute('''  
            CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            email TEXT,
            contrasena TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Si se actualiza desde la versión 1 a la 2, añadimos la columna contrasena
        if (oldVersion == 1 && newVersion == 2) {
          await db.execute('ALTER TABLE usuarios ADD COLUMN contrasena TEXT DEFAULT ""');
        }
      },
    );
  }
}