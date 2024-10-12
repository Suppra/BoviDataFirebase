import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Animal>> fetchAnimals() async {
    QuerySnapshot snapshot = await _firestore.collection('animales').get();
    return snapshot.docs.map((doc) => Animal.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addAnimal(Animal animal) async {
    await _firestore.collection('animales').add(animal.toFirestore());
  }

  Future<void> updateAnimal(Animal animal) async {
    await _firestore.collection('animales').doc(animal.id).update(animal.toFirestore());
  }

  Future<void> deleteAnimal(String animalId) async {
    await _firestore.collection('animales').doc(animalId).delete();
  }
}
