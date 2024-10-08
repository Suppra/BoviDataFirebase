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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
          Navigator.pushReplacementNamed(context, '/home', arguments: 'Ganadero');
        } else if (userType == 'Veterinario') {
          Navigator.pushReplacementNamed(context, '/home', arguments: 'Veterinario');
        } else if (userType == 'Empleado') {
          Navigator.pushReplacementNamed(context, '/home', arguments: 'Empleado');
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
          image: DecorationImage(
            image: NetworkImage('https://cdn.pixabay.com/photo/2017/10/28/06/48/cow-2896329_960_720.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 120),
            Card(
              color: Colors.green,
              margin: EdgeInsets.all(10.0),
              elevation: 6.0,
              child: Container(
                margin: EdgeInsets.all(16.0),
                child: Form(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: _loadPictureLogin(),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Bienvenido a",
                          style: TextStyle(fontSize: 25.0, color: Colors.white),
                        ),
                        Text(
                          "BoviData",
                          style: TextStyle(fontSize: 30.0, color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: "Usuario:",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Contraseña:",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_userController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                              _validateUser();
                            } else {
                              _showAlertDialog('No se permiten campos vacíos');
                            }
                          },
                          child: Text('Entrar'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _validationMessage,
                          style: TextStyle(fontSize: 20.0, color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            '¿No tienes una cuenta? Regístrate aquí',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
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
