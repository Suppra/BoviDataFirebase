import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'vista/auth/login_screen.dart';
import 'vista/auth/register_screen.dart';
import 'vista/home/home_screen.dart';
import 'vista/animal_management/animal_management_screen.dart';
import 'vista/treatments/treatment_vaccine_management_screen.dart';
import 'vista/incident_mortality_report/incident_mortality_report_screen.dart';
import 'vista/inventory/inventory_management_screen.dart';
import 'vista/vaccination/vaccination_planning_screen.dart';
import 'vista/complaints_suggestions/complaints_suggestions_screen.dart';
import 'vista/animal_management/animal_list_screen.dart';
import 'vista/animal_management/animal_profile_edit_screen.dart';
import 'vista/medicalhistory/medical_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(BoviDataApp());
}

class BoviDataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BoviData',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/animal_management': (context) => AnimalRegistrationScreen(),
        '/treatment_vaccine_management': (context) =>
            TreatmentVaccineManagementScreen(),
        '/incident_mortality_report': (context) =>
            IncidentMortalityReportScreen(),
        '/inventory_management': (context) => InventoryManagementScreen(),
        '/vaccination_planning': (context) => VaccinationPlanningScreen(),
        '/complaints_suggestions': (context) => ComplaintsSuggestionsScreen(),
        '/animal_list': (context) => AnimalListScreen(),
        '/animal_profile_edit': (context) => AnimalProfileEditScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/medical_history') {
          final args = settings.arguments as Map<String, dynamic>;
          final animalId = args['animalId'] as String;
          final animalName = args['animalName'] as String;
          return MaterialPageRoute(
            builder: (context) => MedicalHistoryScreen(
              animalId: animalId,
              animalName: animalName,
            ),
          );
        }
        return null;
      },
    );
  }
}
