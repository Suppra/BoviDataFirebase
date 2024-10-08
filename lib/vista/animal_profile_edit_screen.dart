import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalProfileEditScreen extends StatefulWidget {
  @override
  _AnimalProfileEditScreenState createState() => _AnimalProfileEditScreenState();
}

class _AnimalProfileEditScreenState extends State<AnimalProfileEditScreen> {
  late String animalId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el ID del animal desde los argumentos
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    animalId = args['animalId'];
    _loadAnimalData();
  }

  Future<void> _loadAnimalData() async {
    try {
      DocumentSnapshot animalDoc = await FirebaseFirestore.instance
          .collection('animales')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        setState(() {
          _nameController.text = animalDoc['Nombre'] ?? '';
          _breedController.text = animalDoc['Raza'] ?? '';
          _weightController.text = animalDoc['Peso'].toString();
          _dobController.text = animalDoc['FechaNacimiento'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos del animal')),
      );
    }
  }

  Future<void> _updateAnimalData() async {
    try {
      await FirebaseFirestore.instance
          .collection('animales')
          .doc(animalId)
          .update({
        'Nombre': _nameController.text,
        'Raza': _breedController.text,
        'Peso': double.parse(_weightController.text),
        'FechaNacimiento': _dobController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos del animal actualizados con éxito')),
      );
      Navigator.pop(context); // Cierra la pantalla después de la actualización
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil del Animal'),
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
              onPressed: _updateAnimalData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Actualizar Datos'),
            ),
          ],
        ),
      ),
    );
  }
}
