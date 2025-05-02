import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/data/modelo/usuario_modelo.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/usuario_provider.dart';

class MemberDetailScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const MemberDetailScreen({super.key, required this.usuario});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario.nombre);
    _emailController = TextEditingController(text: widget.usuario.email);
    _passwordController = TextEditingController(text: widget.usuario.contrasena);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers to original values if canceling edit
        _nameController.text = widget.usuario.nombre;
        _emailController.text = widget.usuario.email;
        _passwordController.text = widget.usuario.contrasena;
      }
    });
  }

  Future<void> _saveChanges() async {
    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    
    final updatedUsuario = UsuarioModel(
      id: widget.usuario.id,
      nombre: _nameController.text,
      email: _emailController.text,
      contrasena: _passwordController.text,
    );
    
    final success = await usuarioProvider.actualizarUsuario(updatedUsuario);
    
    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información del miembro actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${usuarioProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarText = widget.usuario.nombre.isNotEmpty 
        ? widget.usuario.nombre.substring(0, 1).toUpperCase()
        : '?';
        
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Miembro' : 'Detalle del Miembro'),
        backgroundColor: const Color.fromARGB(255, 38, 94, 235),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'member-${widget.usuario.id}',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue,
                        child: Text(
                          avatarText,
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isEditing) ...[
                    const Text(
                      'Nombre:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Email:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Contraseña:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ] else ...[
                    Text(
                      widget.usuario.nombre,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Color.fromARGB(255, 255, 255, 255)),
                        const SizedBox(width: 5),
                        Text(
                          widget.usuario.email,
                          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      'Información del Miembro',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('ID de Usuario'),
                      subtitle: Text('${widget.usuario.id}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Contraseña'),
                      subtitle: const Text('●●●●●●●●'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha de registro'),
                      subtitle: const Text('Información no disponible'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}