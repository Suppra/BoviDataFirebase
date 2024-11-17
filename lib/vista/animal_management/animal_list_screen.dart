import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../medicalhistory/medical_history_screen.dart'; // Update with the correct path to MedicalHistoryScreen
import '../animal_management/animal_profile_edit_screen.dart'; // Update with the correct path to AnimalProfileEditScreen

class AnimalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final bool isMedicalHistory =
        args != null && args['isMedicalHistory'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listado de Animales',
          style: TextStyle(color: Colors.white),
        ),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('animales').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.green[800]),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los animales.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay animales registrados.'));
            }

            final animals = snapshot.data!.docs;
            return ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                final animalName = animal['Nombre'] ?? 'Sin nombre';
                final animalBreed = animal['Raza'] ?? 'Sin raza';
                final animalWeight = animal['Peso']?.toString() ?? 'Sin peso';
                final animalDob = (animal['FechaNacimiento'] as Timestamp).toDate();
                final formattedDob = DateFormat('dd/MM/yyyy').format(animalDob);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.pets, color: Colors.green[700], size: 30),
                    title: Text(
                      animalName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    subtitle: Text(
                      'Raza: $animalBreed\nPeso: $animalWeight kg\nFecha de Nacimiento: $formattedDob',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMedicalHistory)
                          IconButton(
                            icon: Icon(Icons.history, color: Colors.green[400]),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MedicalHistoryScreen(
                                    animalId: animal.id,
                                    animalName: animalName,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (!isMedicalHistory)
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green[400]),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnimalProfileEditScreen(),
                                  settings: RouteSettings(
                                    arguments: {'animalId': animal.id},
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
