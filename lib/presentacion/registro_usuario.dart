import 'package:flutter/material.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/dominio/repositorio/usuario_repositorio.dart';
import 'package:ProyectoFinalLibreriaUSFQ/presentacion/login_screen.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  // Instancia del repositorio para manejar la base de datos
  final UsuarioRepositorio usuarioRepositorio = UsuarioRepositorio();
  // Lista para almacenar los usuarios recuperados de la base de datos
  List<UsuarioModel> usuarios = [];

  // Controladores para capturar el texto de los TextFields
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  // initState se ejecuta una vez cuando la página se inicializa
  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  // Método para cargar usuarios desde la base de datos
  Future<void> _cargarUsuarios() async {
    final data = await usuarioRepositorio.obtenerUsuarios();
    setState(() {
      usuarios = data; // Actualiza la lista de usuarios
    });
  }

  // Método para agregar un nuevo usuario
  Future<void> _agregarUsuario() async {
    // Validar que los campos no estén vacíos
    if (nombreController.text.isEmpty || 
        emailController.text.isEmpty || 
        contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los campos son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear un nuevo usuario con los datos ingresados
    final nuevoUsuario = UsuarioModel(
      id: 0, // id = 0 para que SQLite lo autogenere
      nombre: nombreController.text,
      email: emailController.text,
      contrasena: contrasenaController.text,
    );

    // Insertar el nuevo usuario en la base de datos
    await usuarioRepositorio.insertarUsuario(nuevoUsuario);
    
    // Limpiar los campos después de agregar
    nombreController.clear();
    emailController.clear();
    contrasenaController.clear();
    
    _cargarUsuarios();
  }

  // Método para eliminar un usuario por id
  Future<void> _eliminarUsuario(int id) async {
    await usuarioRepositorio.eliminarUsuario(id);
    _cargarUsuarios(); // Actualizar lista de usuarios
  }

  // Método para editar un usuario
  Future<void> _editarUsuario(UsuarioModel usuario) async {
    nombreController.text = usuario.nombre;
    emailController.text = usuario.email;
    contrasenaController.text = usuario.contrasena;

    // Mostrar un Dialog para editar los datos del usuario
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final usuarioEditado = UsuarioModel(
                  id: usuario.id,
                  nombre: nombreController.text,
                  email: nombreController.text,
                  contrasena: contrasenaController.text,
                );
                await usuarioRepositorio.actualizarUsuario(usuarioEditado);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                _cargarUsuarios(); // Actualizar lista de usuarios
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios - SQlite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: contrasenaController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _agregarUsuario,
              child: const Text('Agregar Usuario'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  return Card(
                    child: ListTile(
                      title: Text(usuario.nombre),
                      subtitle: Text(usuario.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarUsuario(usuario),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarUsuario(usuario.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}