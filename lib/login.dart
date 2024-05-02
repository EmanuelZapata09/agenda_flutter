import 'package:flutter/material.dart';
import 'package:flutter_application_1/agenda.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Hacer el fondo transparente
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0073B9),
                Color(0xFF015C95),
                Color(0xFF001725),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://img.freepik.com/vector-gratis/logo-moto-vintage-dibujado-mano_23-2149432259.jpg?size=338&ext=jpg&ga=GA1.1.539837299.1711929600&semt=ais',
                  height: 100,
                  width: 100,
                ),
                const SizedBox(
                  height: 100.0,
                ),
                const Text(
                  "Motors Up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iniciar Sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                inputCorreo(),
                const SizedBox(
                  height: 25.0,
                ),
                inputContrasena(),
                const SizedBox(
                  height: 25.0,
                ),
                botonIniciar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputCorreo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: "Correo",
          hintText: "emanuelzpx@gmail.com",
          prefixIcon: Icon(Icons.mail),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Widget inputContrasena() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Contraseña",
          hintText: "***",
          prefixIcon: Icon(Icons.lock),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Widget botonIniciar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _iniciarSesion();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0073B9),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Text(
          'Iniciar Sesión',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _iniciarSesion() async {
    final String correo = _emailController.text.trim();
    final String contrasena = _passwordController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      // Mostrar un mensaje de error si el correo o la contraseña están vacíos
      _mostrarMensaje('Por favor, completa todos los campos.');
      return;
    }

    // Realizar la solicitud HTTP a la API
    final url = Uri.parse('http://localhost:8081/api/auth/login');
    final response = await http.post(
      url,
      body: {
        'correoEmpleado': correo,
        'contrasena': contrasena,
      },
    );

    // Manejar la respuesta de la API
    if (response.statusCode == 200) {
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const Agenda()));
    } else if (response.statusCode == 404) {
      _mostrarMensaje('Usuario no encontrado en la base de datos');
    } else if (response.statusCode == 403) {
      // Mostrar un mensaje si el usuario está inactivo
      _mostrarMensaje('El usuario está inactivo');
    } else {
      // Mostrar un mensaje de error genérico si ocurre otro tipo de error
      _mostrarMensaje('Correo/Contraseña Incorrectos.');
    }
  }

  void _mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensaje'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
