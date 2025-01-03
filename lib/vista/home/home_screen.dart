import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String userType =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BoviData', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 4,
        centerTitle: true,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userType', isEqualTo: userType)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(userType: userType),
                      ),
                    );
                  },
                );
              }

              int notificationCount = snapshot.data!.docs.length;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(userType: userType),
                        ),
                      );
                    },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 2,
                      top: 1,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 43, 156, 21),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            Expanded(
              child: _buildOptionsGrid(context, userType),
            ),
            const SizedBox(height: 20),
            _buildAnimatedLogoutButton(context),
            const SizedBox(height: 20),
            _buildLogo(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        'Bienvenido a BoviData',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, String userType) {
    final List<Map<String, dynamic>> options = [
     
      if (userType == 'Veterinario') ...[
        {'label': 'Tratamientos y Vacunas', 'icon': Icons.medical_services, 'route': '/treatment_vaccine_management'},
        {'label': 'Inventario de Medicamentos', 'icon': Icons.inventory, 'route': '/inventory_management'},
        {'label': 'Planificación Vacunación', 'icon': Icons.calendar_today, 'route': '/vaccination_planning'},
        {'label': 'Reportar Incidencias', 'icon': Icons.report, 'route': '/incident_mortality_report'},
        {'label': 'Historial Médico', 'icon': Icons.history, 'route': '/animal_list', 'args': {'isMedicalHistory': true}},
      ],
      if (userType == 'Ganadero') ...[
        {'label': 'Gestión de Bovinos', 'icon': Icons.pets, 'route': '/animal_management'},
        {'label': 'Listado de Bovinos', 'icon': Icons.list, 'route': '/animal_list'},
        {'label': 'Quejas y Sugerencias', 'icon': Icons.feedback, 'route': '/complaints_suggestions'},
        {'label': 'Exportación de Datos', 'icon': Icons.file_download, 'route': '/data_export'},
        {'label': 'Historial Médico', 'icon': Icons.history, 'route': '/animal_list', 'args': {'isMedicalHistory': true}},
      ],
      if (userType == 'Empleado') ...[
        {'label': 'Reportar Incidencias', 'icon': Icons.report_problem, 'route': '/incident_mortality_report'},
        {'label': 'Quejas y Sugerencias', 'icon': Icons.feedback, 'route': '/complaints_suggestions'},
      ],
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildOptionCard(
          context,
          option['icon'],
          option['label'],
          option['route'],
          args: option['args'],
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, IconData icon, String label, String route, {Map<String, dynamic>? args}) {
    return GestureDetector(
      onTap: () {
        if (route == '/data_export') {
          _showAnimalSelectionDialog(context);
        } else {
          Navigator.pushNamed(context, route, arguments: args);
        }
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.green[100]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.green[800]),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnimalSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Seleccionar Bovino'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('animales').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final animals = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];
                  return ListTile(
                    title: Text(animal['Nombre']),
                    onTap: () {
                      Navigator.pop(context);
                      exportDataToPdf(context, animal.id);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> exportDataToPdf(BuildContext context, String animalId) async {
    final pdf = pw.Document();

    // Obtener datos del bovino
    final animalDoc = await FirebaseFirestore.instance.collection('animales').doc(animalId).get();
    final animalData = animalDoc.data();

    // Obtener historial médico
    final medicalHistorySnapshot = await FirebaseFirestore.instance
        .collection('medical_history')
        .where('animalId', isEqualTo: animalId)
        .get();
    final medicalHistory = medicalHistorySnapshot.docs.map((doc) => doc.data()).toList();

    // Obtener incidencias
    final incidentsSnapshot = await FirebaseFirestore.instance
        .collection('incidents')
        .where('animalId', isEqualTo: animalId)
        .get();
    final incidents = incidentsSnapshot.docs.map((doc) => doc.data()).toList();

    // Crear el contenido del PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Datos del Bovino', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Nombre: ${animalData?['Nombre'] ?? 'N/A'}'),
              pw.Text('Raza: ${animalData?['Raza'] ?? 'N/A'}'),
              pw.Text('Peso: ${animalData?['Peso'] ?? 'N/A'} kg'),
              pw.Text('Fecha de Nacimiento: ${animalData?['FechaNacimiento'] != null ? (animalData!['FechaNacimiento'] as Timestamp).toDate().toString() : 'N/A'}'),
              pw.SizedBox(height: 20),
              pw.Text('Historial Médico', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...medicalHistory.map((history) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Fecha: ${(history['date'] as Timestamp).toDate().toString()}'),
                    pw.Text('Descripción: ${history['description'] ?? 'N/A'}'),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Text('Incidencias', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...incidents.map((incident) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Fecha: ${(incident['date'] as Timestamp).toDate().toString()}'),
                    pw.Text('Descripción: ${incident['description'] ?? 'N/A'}'),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    // Mostrar el PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Widget _buildAnimatedLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _logout(context);
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logoBovidata.jpg',
        height: 120,
        width: 120,
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }
}

class NotificationsScreen extends StatelessWidget {
  final String userType;

  NotificationsScreen({required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userType', isEqualTo: userType)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green[800]));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las notificaciones: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay notificaciones.'));
          }

          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  FirebaseFirestore.instance.collection('notifications').doc(notification.id).delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notificación eliminada')),
                  );
                },
                background: Container(
                  color: const Color.fromARGB(255, 69, 175, 37),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: ListTile(
                    title: Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notification['message']),
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
