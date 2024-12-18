import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer.dart';
import 'property.dart';

enum EventType {
  HouseIntroduction, // 집 소개
  PreContract, // 가계약
  Contract, // 계약
  Meeting, // 미팅
  PaymentDate, // 잔금일
  MoveInDate, // 입주일
  Other, // 기타
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final EventType type;
  final Customer? customer;
  final Property? property;
  final bool isCompleted;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    required this.type,
    this.customer,
    this.property,
    this.isCompleted = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'] as String?,
      type: EventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EventType.Other,
      ),
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      property: json['property'] != null
          ? Property.fromMap(json['property'] as Map<String, dynamic>,
              json['property']['id'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type.toString(),
      'customer': customer?.toJson(),
      'property': property?.toMap(),
      'isCompleted': isCompleted,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? description,
    EventType? type,
    Customer? customer,
    Property? property,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      customer: customer ?? this.customer,
      property: property ?? this.property,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
