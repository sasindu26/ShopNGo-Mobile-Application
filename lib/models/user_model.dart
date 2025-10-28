class UserModel {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String address; // New address field
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.address, // Make it required
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'address': address, // Add to map
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      role: map['role'],
      name: map['name'],
      address: map['address'] ?? '', // Default to empty string if missing
      photoUrl: map['photoUrl'],
    );
  }
}