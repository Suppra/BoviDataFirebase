import '../services/firestore_service.dart';
import '../models/animal_model.dart';

class AnimalController {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<Animal>> getAnimals() async {
    return await _firestoreService.fetchAnimals();
  }

  Future<void> addAnimal(Animal animal) async {
    await _firestoreService.addAnimal(animal);
  }

  Future<void> updateAnimal(Animal animal) async {
    await _firestoreService.updateAnimal(animal);
  }

  Future<void> deleteAnimal(String animalId) async {
    await _firestoreService.deleteAnimal(animalId);
  }
}
