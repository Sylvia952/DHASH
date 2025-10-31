import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId? id;
  final String email;
  final String password; // Hashé
  final String profilePhotoURL;
  final bool isVerified;
  final bool isAdmin;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.profilePhotoURL,
    this.isVerified = false,
    this.isAdmin = false,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Convertir l'objet Dart en Map (pour MongoDB)
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'profilePhotoURL': profilePhotoURL,
      'isVerified': isVerified,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }
  
  // Convertir une Map (de MongoDB) en objet Dart
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId,
      email: map['email'] as String,
      password: map['password'] as String,
      profilePhotoURL: map['profilePhotoURL'] as String,
      isVerified: map['isVerified'] as bool,
      isAdmin: map['isAdmin'] as bool,
      createdAt: map['createdAt'] as DateTime,
    );
  }
}