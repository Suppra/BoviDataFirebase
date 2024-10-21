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
        Navigator.pushReplacementNamed(context, '/home', arguments: userType);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _buildBackground(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    SizedBox(height: 120), // Espacio sin el logo superior
                    _buildHeader(),
                    SizedBox(height: 40),
                    _buildTextField(
                        _userController, "Correo Electrónico", Icons.email),
                    SizedBox(height: 20),
                    _buildTextField(_passwordController, "Contraseña", Icons.lock,
                        isPassword: true),
                    SizedBox(height: 30),
                    _buildLoginButton(),
                    SizedBox(height: 10),
                    _buildForgotPasswordButton(context), // Nuevo botón
                    SizedBox(height: 10),
                    _buildRegisterText(),
                    SizedBox(height: 20),
                    _buildErrorMessage(),
                    SizedBox(height: 50),
                    _buildLogo(), // Logo en la parte inferior
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[800]!, Colors.green[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Bienvenido!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Inicia sesión en tu cuenta para continuar',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
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
        filled: true,
        fillColor: Colors.green[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_userController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty) {
            _validateUser();
          } else {
            _showAlertDialog('No se permiten campos vacíos');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        child: Text(
          'Ingresar',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/password_recovery'); // Navega a recuperación
      },
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          fontSize: 16,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildRegisterText() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: Text(
          '¿No tienes una cuenta? Regístrate aquí',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green[800],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Text(
        _validationMessage,
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logoBovidata.jpg',
        height: 280,
        width: 280,
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }
}
