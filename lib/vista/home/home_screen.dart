import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String userType =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('BoviData - Inicio'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[300]!, Colors.teal[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido a BoviData',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 30),
            _buildButton(context, Icons.pets, 'Gestión de Animales',
                '/animal_management'),
            _buildButton(
                context, Icons.list, 'Listado de Animales', '/animal_list'),
            if (userType == 'Veterinario') ...[
              _buildButton(
                  context,
                  Icons.medical_services,
                  'Gestión de Tratamientos y Vacunas',
                  '/treatment_vaccine_management'),
              _buildButton(
                  context,
                  Icons.inventory,
                  'Gestión de Inventario de Medicamentos',
                  '/inventory_management'),
              _buildButton(context, Icons.calendar_today,
                  'Planificación de Vacunación', '/vaccination_planning'),
              _buildButton(
                  context,
                  Icons.report,
                  'Reportar Incidencias y Mortalidad',
                  '/incident_mortality_report'),
              _buildMedicalHistoryButton(context),
            ],
            if (userType == 'Ganadero') ...[
              _buildButton(context, Icons.feedback, 'Quejas y Sugerencias',
                  '/complaints_suggestions'),
              _buildButton(context, Icons.file_download, 'Exportación de Datos',
                  '/data_export'),
              _buildMedicalHistoryButton(context),
            ],
            if (userType == 'Empleado') ...[
              _buildButton(context, Icons.report_problem,
                  'Reportar Incidencias', '/incident_mortality_report'),
              _buildButton(context, Icons.feedback, 'Quejas y Sugerencias',
                  '/complaints_suggestions'),
            ],
            SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // Método para construir botones de manera uniforme
  Widget _buildButton(
      BuildContext context, IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.teal[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Botón para el historial médico
  Widget _buildMedicalHistoryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Navegar a la lista de animales para seleccionar uno y ver su historial médico
          Navigator.pushNamed(
            context,
            '/animal_list',
            arguments: <String, dynamic>{'isMedicalHistory': true},
          );
        },
        icon: Icon(Icons.history, color: Colors.white),
        label: Text('Historial Médico'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.teal[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Botón para cerrar sesión
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _logout(context);
        },
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.red[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Método para manejar el cierre de sesión
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }
}
