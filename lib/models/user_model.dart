class UserModel {
  String uid;
  String email;
  String userType;

  UserModel({required this.uid, required this.email, required this.userType});

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      userType: data['userType'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
    };
  }
}
