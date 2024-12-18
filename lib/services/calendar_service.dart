// lib/services/calendar_service.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // table_calendar 패키지 임포트
import '../models/event.dart';
import '../models/customer.dart';
import '../models/property.dart';

class CalendarService extends ChangeNotifier {
  final List<Event> _events = [];
  final List<Customer> _customers = [];
  final List<Property> _properties = [
    // 예시 매물 데이터
    Property(
      id: 'property1',
      userId: 'example_user_id',
      name: '매물 1',
      price: '1억 5000만',
      ownerName: '홍길동',
      phoneNumber: '010-1234-5678',
      area: '32평',
      status: '대기',
      images: ['https://via.placeholder.com/150'],
      propertyType: '아파트',
      transactionType: '매매',
    ),
    // 추가 매물 데이터...
  ];

  List<Event> get events => _events;
  List<Customer> get customers => _customers;
  List<Property> get properties => _properties;

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void deleteCustomer(Customer customer) {
    _customers.remove(customer);
    notifyListeners();
  }

  void addProperty(Property property) {
    _properties.add(property);
    notifyListeners();
  }

  void deleteProperty(Property property) {
    _properties.remove(property);
    notifyListeners();
  }
}
