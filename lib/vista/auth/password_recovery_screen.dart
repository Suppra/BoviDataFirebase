import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.isEmpty) {
      _showAlertDialog('Por favor, ingrese su correo electrónico.');
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message =
            'Correo de recuperación enviado. Verifica tu bandeja de entrada.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error al enviar el correo de recuperación.';
      });
    }
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.teal[800])),
          ),
        ],
      ),
    );
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
                    SizedBox(height: 80),
                    _buildHeader(),
                    SizedBox(height: 40),
                    _buildEmailField(),
                    SizedBox(height: 20),
                    _buildSendButton(),
                    SizedBox(height: 20),
                    _buildMessage(),
                    SizedBox(height: 50),
                    _buildBackToLoginButton(context),
                    SizedBox(height: 20),
                    _buildLogo(),
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
            colors: [Colors.teal[800]!, Colors.teal[300]!],
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
      children: [
        Text(
          'Recuperación de Contraseña',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 240, 243, 243),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 248, 245, 245)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: Colors.teal[800]),
        labelText: 'Correo Electrónico',
        filled: true,
        fillColor: Colors.teal[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sendPasswordResetEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[700],
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        child: Text(
          'Enviar Enlace de Recuperación',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Center(
      child: Text(
        _message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.teal[800]),
      ),
    );
  }

  Widget _buildBackToLoginButton(BuildContext context) {
  return TextButton(
    onPressed: () {
      Navigator.pop(context); // Cierra esta pantalla y regresa al Login
    },
    child: Text(
      '¿Ya recuerdas tu contraseña? Inicia sesión',
      style: TextStyle(fontSize: 16, color: Colors.teal[800]),
    ),
  );
}


  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logoBovidata.jpg',
        height: 200,
        width: 200,
      ),
    );
  }
}
