import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/presentacion/login_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/auth_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/usuario_provider.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar usuarios al iniciar la pantalla
    Future.microtask(() {
      Provider.of<UsuarioProvider>(context, listen: false).cargarUsuarios();
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    super.dispose();
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

    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    
    final resultado = await usuarioProvider.agregarUsuario(
      nombreController.text.trim(),
      emailController.text.trim(),
      contrasenaController.text.trim(),
    );

    if (resultado) {
      // Limpiar los campos después de agregar
      nombreController.clear();
      emailController.clear();
      contrasenaController.clear();
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
            Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, _) {
                return ElevatedButton(
                  onPressed: () async {
                    final usuarioEditado = UsuarioModel(
                      id: usuario.id,
                      nombre: nombreController.text,
                      email: emailController.text,
                      contrasena: contrasenaController.text,
                    );
                    
                    await usuarioProvider.actualizarUsuario(usuarioEditado);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar Cambios'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar un usuario
  Future<void> _eliminarUsuario(int id) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Provider.of<UsuarioProvider>(context, listen: false).eliminarUsuario(id);
    }
  }

  // Método para cerrar sesión
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
        title: const Text('Usuarios - SQlite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulario para crear usuarios
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agregar Nuevo Usuario',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contrasenaController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _agregarUsuario,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Guardar Usuario'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de usuarios
          Expanded(
            child: Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, _) {
                final usuarios = usuarioProvider.usuarios;
                
                if (usuarios.isEmpty) {
                  return const Center(
                    child: Text('No hay usuarios registrados'),
                  );
                }
                
                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(usuario.nombre.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(usuario.nombre),
                        subtitle: Text(usuario.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarUsuario(usuario),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarUsuario(usuario.id),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}