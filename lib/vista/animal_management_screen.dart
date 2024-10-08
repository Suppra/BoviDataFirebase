import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalRegistrationScreen extends StatefulWidget {
  @override
  _AnimalRegistrationScreenState createState() => _AnimalRegistrationScreenState();
}

class _AnimalRegistrationScreenState extends State<AnimalRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Future<void> _registerAnimal() async {
    try {
      // Crear un nuevo documento con un ID único en Firestore
      DocumentReference newAnimalRef = FirebaseFirestore.instance.collection('animales').doc();

      // Crear el animal con la información proporcionada
      await newAnimalRef.set({
        'Nombre': _nameController.text,
        'Raza': _breedController.text,
        'Peso': double.parse(_weightController.text),
        'FechaNacimiento': _dobController.text,
        'AnimalID': newAnimalRef.id, // Asignar el ID único generado al animal
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal registrado con éxito')),
      );
      Navigator.pop(context); // Cierra la pantalla después de registrar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el animal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Animal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del Animal'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _breedController,
              decoration: InputDecoration(labelText: 'Raza'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(labelText: 'Fecha de Nacimiento (DD/MM/AAAA)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerAnimal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Registrar Animal'),
            ),
          ],
        ),
      ),
    );
  }
}
