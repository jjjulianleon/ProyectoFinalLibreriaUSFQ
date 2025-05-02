import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/auth_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/providers/usuario_provider.dart';
import 'package:ProyectoFinalLibreriaUSFQ/biblioteca/main_biblioteca.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = await authProvider.iniciarSesion(
      emailController.text.trim(),
      contrasenaController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (loggedIn) {
      // Si el inicio de sesión es exitoso, navegamos a la pantalla principal de la biblioteca
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } else {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarDialogoRegistro() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController emailRegController = TextEditingController();
    final TextEditingController contrasenaRegController = TextEditingController();
    final TextEditingController confirmarContrasenaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear nueva cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailRegController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contrasenaRegController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmarContrasenaController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, _) {
                return ElevatedButton(
                  onPressed: () async {
                    // Validar campos
                    if (nombreController.text.isEmpty ||
                        emailRegController.text.isEmpty ||
                        contrasenaRegController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Todos los campos son obligatorios'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Validar que las contraseñas coincidan
                    if (contrasenaRegController.text != confirmarContrasenaController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // Registrar el usuario
                    final resultado = await usuarioProvider.agregarUsuario(
                      nombreController.text,
                      emailRegController.text,
                      contrasenaRegController.text,
                    );
                    
                    Navigator.of(context).pop();
                    
                    if (resultado) {
                      // Si el registro es exitoso, mostrar mensaje y poner las credenciales en el formulario de login
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario registrado correctamente. Ahora puedes iniciar sesión.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Autocompletar el formulario de login con las credenciales registradas
                      setState(() {
                        emailController.text = emailRegController.text;
                        contrasenaController.text = contrasenaRegController.text;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(usuarioProvider.errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Registrar'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: contrasenaController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Iniciar Sesión'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _mostrarDialogoRegistro,
                          child: const Text(
                            '¿No tienes cuenta aún? Crear una cuenta',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}