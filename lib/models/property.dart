// lib/models/property.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String name;
  final String price;
  final String ownerName;
  final String phoneNumber;
  final String area;
  final String status;
  final List<String> images;
  final String? address;
  final String? contractorName;
  final String? contractorPhone;
  final String? notes;
  final String? propertyType;
  final String transactionType;
  final DateTime createdAt;
  final String userId;

  static const List<String> propertyTypes = ['아파트', '원룸', '토지', '단독', '상가점포'];

  static const List<String> transactionTypes = ['매매', '전세', '월세'];

  Property({
    required this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.ownerName,
    required this.phoneNumber,
    required this.area,
    required this.status,
    required this.images,
    this.address,
    this.contractorName,
    this.contractorPhone,
    this.notes,
    this.propertyType,
    required this.transactionType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'price': price,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'area': area,
      'status': status,
      'images': images,
      'address': address,
      'contractorName': contractorName,
      'contractorPhone': contractorPhone,
      'notes': notes,
      'propertyType': propertyType,
      'transactionType': transactionType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      area: map['area'] ?? '',
      status: map['status'] ?? '대기',
      images: List<String>.from(map['images'] ?? []),
      address: map['address'],
      contractorName: map['contractorName'],
      contractorPhone: map['contractorPhone'],
      notes: map['notes'],
      propertyType: map['propertyType'],
      transactionType: map['transactionType'] ?? '매매',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
