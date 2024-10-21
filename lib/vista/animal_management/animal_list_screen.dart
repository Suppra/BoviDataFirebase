import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados a la pantalla
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final bool isMedicalHistory =
        args != null && args['isMedicalHistory'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Animales', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('animales').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los datos'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay animales registrados'));
            }

            final animals = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                final animalName = animal['Nombre'] ?? 'Sin nombre';
                final animalId = animal['AnimalID'] ?? 'ID no disponible';

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      animalName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    subtitle: Text(
                      'ID: $animalId',
                      style: TextStyle(color: Colors.teal[600]),
                    ),
                    leading: Icon(Icons.pets, color: Colors.teal[400], size: 36),
                    trailing: _buildActionButtons(context, animalId, animalName, isMedicalHistory),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String animalId, String animalName, bool isMedicalHistory) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue[400], size: 28),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/animal_profile_edit',
              arguments: {'animalId': animalId},
            );
          },
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: Colors.teal[400], size: 28),
          onPressed: () {
            if (isMedicalHistory) {
              Navigator.pushNamed(
                context,
                '/medical_history',
                arguments: {
                  'animalId': animalId,
                  'animalName': animalName,
                },
              );
            }
          },
        ),
      ],
    );
  }
}
