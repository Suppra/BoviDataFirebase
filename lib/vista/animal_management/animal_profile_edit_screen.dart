import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnimalProfileEditScreen extends StatefulWidget {
  @override
  _AnimalProfileEditScreenState createState() =>
      _AnimalProfileEditScreenState();
}

class _AnimalProfileEditScreenState extends State<AnimalProfileEditScreen> {
  late String animalId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
          _selectedDate = (animalDoc['FechaNacimiento'] as Timestamp).toDate();
          _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        });
      }
    } catch (e) {
      _showSnackBar('Error al cargar los datos del animal');
    }
  }

  Future<void> _updateAnimalData() async {
    try {
      await FirebaseFirestore.instance.collection('animales').doc(animalId).update({
        'Nombre': _nameController.text,
        'Raza': _breedController.text,
        'Peso': double.parse(_weightController.text),
        'FechaNacimiento': Timestamp.fromDate(_selectedDate!), // Cambiado aquí
      });

      _showSnackBar('Datos del animal actualizados con éxito');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error al actualizar los datos');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil del Animal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Nombre del Animal', _nameController),
            SizedBox(height: 15),
            _buildTextField('Raza', _breedController),
            SizedBox(height: 15),
            _buildTextField('Peso (kg)', _weightController, isNumeric: true),
            SizedBox(height: 15),
            _buildDatePickerField('Fecha de Nacimiento', _dobController),
            SizedBox(height: 30),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
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
            filled: true,
            fillColor: Colors.green[50],
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.green[800]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton.icon(
      onPressed: _updateAnimalData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      icon: Icon(Icons.save, color: Colors.white),
      label: Text(
        'Actualizar Datos',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
