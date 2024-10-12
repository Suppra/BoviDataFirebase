class Animal {
  String id;
  String name;
  String breed;
  double weight;
  String dob;

  Animal({required this.id, required this.name, required this.breed, required this.weight, required this.dob});

  factory Animal.fromFirestore(Map<String, dynamic> data) {
    return Animal(
      id: data['id'],
      name: data['name'],
      breed: data['breed'],
      weight: data['weight'],
      dob: data['dob'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'weight': weight,
      'dob': dob,
    };
  }
}
