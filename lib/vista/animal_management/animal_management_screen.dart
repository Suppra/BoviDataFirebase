import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalRegistrationScreen extends StatefulWidget {
  @override
  _AnimalRegistrationScreenState createState() =>
      _AnimalRegistrationScreenState();
}

class _AnimalRegistrationScreenState extends State<AnimalRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedBreed;

  final List<String> _breeds = [
    'Brahman',
    'Cebú (Indo-Brasil)',
    'Simmental (cruzada)',
    'Charolais (cruzada)',
    'Gyr Lechero',
    'Girolando',
    'Pardo Suizo (cruzado)',
    'Costeño con Cuernos',
    'Romosinuano',
    'Blanco Orejinegro (BON)',
    'Sanmartinero',
    'Chino Santandereano (en menor medida)',
  ];

  Future<void> _registerAnimal() async {
    try {
      DocumentReference newAnimalRef =
          FirebaseFirestore.instance.collection('animales').doc();

      await newAnimalRef.set({
        'Nombre': _nameController.text,
        'Raza': _selectedBreed ?? _breedController.text,
        'Peso': double.parse(_weightController.text),
        'FechaNacimiento': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
        'AnimalID': newAnimalRef.id,
      });

      // Enviar notificación a empleados y veterinarios
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Nuevo Animal Registrado',
        'message': 'El ganadero ha registrado un nuevo Bovino.',
        'timestamp': Timestamp.now(),
        'userType': 'Empleado', // Notificación para empleados
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Nuevo Animal Registrado',
        'message': 'El ganadero ha registrado un nuevo Bovino.',
        'timestamp': Timestamp.now(),
        'userType': 'Veterinario', // Notificación para veterinarios
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bovino registrado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar el Bovino'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Bovinos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Nombre del Bovino', _nameController, Icons.pets),
                    SizedBox(height: 15),
                    _buildBreedSelector(),
                    SizedBox(height: 15),
                    _buildTextField('Peso (kg)', _weightController, Icons.line_weight, isNumeric: true),
                    SizedBox(height: 15),
                    _buildDatePickerField('Fecha de Nacimiento', _dobController),
                    SizedBox(height: 30),
                    _buildRegisterButton(),
                    SizedBox(height: 20),
                    _buildLogo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        filled: true,
        fillColor: Colors.green[50],
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBreedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raza',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedBreed,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category, color: Colors.green[800]),
            filled: true,
            fillColor: Colors.green[50],
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          items: _breeds.map((breed) {
            return DropdownMenuItem<String>(
              value: breed,
              child: Text(breed),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBreed = value;
              _breedController.clear();
            });
          },
        ),
        SizedBox(height: 10),
        _buildTextField('Otra Raza (si no está en la lista)', _breedController, Icons.category),
      ],
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          setState(() {
            _selectedDate = pickedDate;
            controller.text = formattedDate;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.calendar_today, color: Colors.green[800]),
            filled: true,
            fillColor: Colors.green[50],
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      onPressed: _registerAnimal,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      icon: Icon(Icons.check, color: Colors.white),
      label: Text(
        'Registrar Bovino',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Image.asset(
        'assets/images/logoBovidata.jpg', // Asegúrate de que el logo esté en la carpeta assets y configurado en pubspec.yaml
        height: 100,
      ),
    );
  }
}