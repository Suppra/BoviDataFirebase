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

  Future<void> _registerAnimal() async {
  try {
    DocumentReference newAnimalRef =
        FirebaseFirestore.instance.collection('animales').doc();

    await newAnimalRef.set({
      'Nombre': _nameController.text,
      'Raza': _breedController.text,
      'Peso': double.parse(_weightController.text),
      'FechaNacimiento': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
      'AnimalID': newAnimalRef.id,
    });

    // Enviar notificación a empleados y veterinarios
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Nuevo Animal Registrado',
      'message': 'El ganadero ha registrado un nuevo animal.',
      'timestamp': Timestamp.now(),
      'userType': 'Empleado', // Notificación para empleados
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Nuevo Animal Registrado',
      'message': 'El ganadero ha registrado un nuevo animal.',
      'timestamp': Timestamp.now(),
      'userType': 'Veterinario', // Notificación para veterinarios
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Animal registrado con éxito'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al registrar el animal'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Animal', style: TextStyle(color: Colors.white)),
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
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _buildTextField('Nombre del Animal', _nameController, Icons.pets),
                        SizedBox(height: 15),
                        _buildTextField('Raza', _breedController, Icons.category),
                        SizedBox(height: 15),
                        _buildTextField('Peso (kg)', _weightController, Icons.line_weight, isNumeric: true),
                        SizedBox(height: 15),
                        _buildDatePickerField('Fecha de Nacimiento', _dobController),
                        SizedBox(height: 30),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                  Spacer(),
                  _buildLogo(),
                ],
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
        'Registrar Animal',
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
