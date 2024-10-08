import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener los argumentos pasados a la pantalla
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Verificar si los argumentos existen y contienen la clave 'isMedicalHistory'
    final bool isMedicalHistory = args != null && args['isMedicalHistory'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Animales'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              final animalName = animal['Nombre'] ?? 'Sin nombre';
              final animalId = animal['AnimalID'] ?? 'ID no disponible';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(animalName),
                  subtitle: Text('ID: $animalId'),
                  leading: Icon(Icons.pets, color: Colors.teal),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navegar a la pantalla de edición de perfil del animal
                          Navigator.pushNamed(
                            context,
                            '/animal_profile_edit',
                            arguments: {
                              'animalId': animalId,
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.teal),
                        onPressed: () {
                          if (isMedicalHistory) {
                            // Navegar al historial médico del animal seleccionado
                            Navigator.pushNamed(
                              context,
                              '/medical_history',
                              arguments: {
                                'animalId': animalId,
                                'animalName': animalName,
                              },
                            );
                          } else {
                            // Lógica para otras funcionalidades si no es historial médico
                          }
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
    );
  }
}
