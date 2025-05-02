import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'member_detail_screen.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/usuario_provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UsuarioModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    // Cargar usuarios al iniciar
    Future.microtask(() {
      Provider.of<UsuarioProvider>(context, listen: false).cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    
    setState(() {
      _filteredUsers = usuarioProvider.usuarios.where((usuario) {
        return usuario.nombre.toLowerCase().contains(query) ||
            usuario.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddMemberDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nuevo miembro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, _) {
                return ElevatedButton(
                  onPressed: () async {
                    final resultado = await usuarioProvider.agregarUsuario(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                    );
                    
                    Navigator.of(context).pop();
                    
                    if (resultado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Miembro agregado correctamente'),
                          backgroundColor: Color.fromARGB(255, 40, 103, 211),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(usuarioProvider.errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    
                    _filterUsers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 97, 183),
                  ),
                  child: const Text('Agregar'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _removeMember(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de que desea eliminar este miembro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          Consumer<UsuarioProvider>(
            builder: (context, usuarioProvider, _) {
              return ElevatedButton(
                onPressed: () async {
                  await usuarioProvider.eliminarUsuario(id);
                  Navigator.of(context).pop();
                  _filterUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Miembros'),
          actions: [
            ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 38, 94, 235),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar miembros...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: Consumer<UsuarioProvider>(
          builder: (context, usuarioProvider, child) {
            if (usuarioProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (usuarioProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${usuarioProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        usuarioProvider.cargarUsuarios();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            // Si no hay búsqueda activa, mostrar todos los usuarios
            final displayUsers = _searchController.text.isEmpty 
                ? usuarioProvider.usuarios 
                : _filteredUsers;
                
            if (displayUsers.isEmpty) {
              return const Center(
                child: Text('No hay miembros para mostrar'),
              );
            }
            
            return ListView.builder(
              itemCount: displayUsers.length,
              itemBuilder: (context, index) {
                final usuario = displayUsers[index];
                final avatarText = usuario.nombre.isNotEmpty 
                    ? usuario.nombre.substring(0, 1).toUpperCase()
                    : '?';
                    
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        avatarText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(usuario.nombre),
                    subtitle: Text(usuario.email),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              MemberDetailScreen(usuario: usuario),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeMember(usuario.id);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}