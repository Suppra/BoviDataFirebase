import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _userType = 'Ganadero';
  String _registerMessage = '';

  Future<void> _registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'Usuario': _emailController.text,
        'Tipo': _userType,
      });

      Navigator.pop(context); // Cerrar la pantalla de registro
    } catch (e) {
      setState(() {
        _registerMessage = "¡Error al registrar usuario!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrar Usuario'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Crear una nueva cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Por favor, completa la información para continuar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              _buildTextField(_emailController, 'Correo Electrónico', Icons.email),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
              SizedBox(height: 20),
              _buildDropdown(),
              SizedBox(height: 30),
              _buildRegisterButton(),
              SizedBox(height: 20),
              Center(
                child: Text(
                  _registerMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _userType,
      decoration: InputDecoration(
        labelText: 'Seleccionar Tipo de Usuario',
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: ['Ganadero', 'Veterinario', 'Empleado']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _userType = value!;
        });
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_emailController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty) {
            _registerUser();
          } else {
            _showAlertDialog('No se permiten campos vacíos');
          }
        },
        style: ElevatedButton.styleFrom(
  backgroundColor: Colors.green[800], 
  padding: EdgeInsets.symmetric(vertical: 18),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 5,
),

        child: Text(
          'Registrar',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
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
}
