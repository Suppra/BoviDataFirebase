import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _validationMessage = '';

  Future<void> _validateUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _userController.text,
        password: _passwordController.text,
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String userType = userDoc['Tipo'];

        if (userType == 'Ganadero') {
          Navigator.pushReplacementNamed(context, '/home',
              arguments: 'Ganadero');
        } else if (userType == 'Veterinario') {
          Navigator.pushReplacementNamed(context, '/home',
              arguments: 'Veterinario');
        } else if (userType == 'Empleado') {
          Navigator.pushReplacementNamed(context, '/home',
              arguments: 'Empleado');
        } else {
          _setValidationMessage("¡Tipo de usuario no reconocido!");
        }
      } else {
        _setValidationMessage("¡Usuario no encontrado en la base de datos!");
      }
    } catch (e) {
      _setValidationMessage("¡Verifique las credenciales!");
    }
  }

  void _setValidationMessage(String message) {
    setState(() {
      _validationMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[800]!, Colors.green[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 120),
            Card(
              color: Colors.white.withOpacity(0.9),
              margin: EdgeInsets.all(10.0),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: _loadPictureLogin(),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Bienvenido a",
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      "BoviData",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_userController, "Usuario", Icons.person),
                    SizedBox(height: 16),
                    _buildTextField(
                        _passwordController, "Contraseña", Icons.lock,
                        isPassword: true),
                    SizedBox(height: 16),
                    _buildLoginButton(),
                    SizedBox(height: 5),
                    Text(
                      _validationMessage,
                      style: TextStyle(fontSize: 16.0, color: Colors.red),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        '¿No tienes una cuenta? Regístrate aquí',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green[800]),
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[800]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green[800]!),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green[600]!),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_userController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          _validateUser();
        } else {
          _showAlertDialog('No se permiten campos vacíos');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 5,
      ),
      child: Text(
        'Ingresar',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alerta, ha ocurrido un error.'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _loadPictureLogin() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = min(constraints.maxHeight / 5, constraints.maxWidth / 5);
        return Center(
          child: ClipOval(
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/logoBovidata.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
