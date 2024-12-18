import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? memo;
  final DateTime createdAt;
  final List<String> interestedProperties;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.memo,
    required this.createdAt,
    required this.interestedProperties,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      memo: json['memo'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      interestedProperties:
          List<String>.from(json['interestedProperties'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'interestedProperties': interestedProperties,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? memo,
    DateTime? createdAt,
    List<String>? interestedProperties,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      interestedProperties: interestedProperties ?? this.interestedProperties,
    );
  }
}
