// lib/screens/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:jibgwan/constants/colors.dart';
import 'package:jibgwan/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/event.dart';
import '../models/property.dart';
import '../services/calendar_service.dart';
// PropertyService 임포트 추가

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final calendarService = Provider.of<CalendarService>(context);
    final events = calendarService.getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '일정 관리',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddEventDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TableCalendar<Event>(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: (day) => calendarService.getEventsForDay(day),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '등록된 일정이 없습니다',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: _getEventIcon(event.type),
                            title: Text(
                              event.property?.name ?? '매물 없음',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(event.customer?.name ?? '고객 정보 없음'),
                                Text(event.customer?.phoneNumber ?? '연락처 없음'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.error),
                              onPressed: () => _showDeleteDialog(
                                  context, calendarService, event),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEventIcon(EventType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case EventType.HouseIntroduction:
        iconData = Icons.home;
        color = AppColors.primary;
        break;
      case EventType.PreContract:
        iconData = Icons.description;
        color = AppColors.accent;
        break;
      case EventType.Contract:
        iconData = Icons.assignment_turned_in;
        color = AppColors.success;
        break;
      case EventType.Meeting:
        iconData = Icons.people;
        color = AppColors.info;
        break;
      case EventType.PaymentDate:
        iconData = Icons.payment;
        color = AppColors.success;
        break;
      case EventType.MoveInDate:
        iconData = Icons.moving;
        color = AppColors.warning;
        break;
      case EventType.Other:
        iconData = Icons.event;
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color),
    );
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    final calendarService =
        Provider.of<CalendarService>(context, listen: false);

    final customer = await _selectCustomer(context, calendarService.customers);
    if (customer == null) return;

    final property =
        await _selectProperty(context, calendarService.properties); // 수정
    if (property == null) return;

    final eventType = await _selectEventType(context);
    if (eventType == null) return;

    await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null) {
        final newEvent = Event(
          id: DateTime.now().toString(),
          title: '일정',
          date: date,
          type: EventType.Meeting,
          customer: customer,
          property: property,
        );
        calendarService.addEvent(newEvent);
      }
    });
  }

  Future<Customer?> _selectCustomer(
      BuildContext context, List<Customer> customers) async {
    return await showDialog<Customer>(
      context: context,
      builder: (context) {
        String? name;
        String? phoneNumber;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '고객 정보 입력',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '고객 이름',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '전화번호',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => phoneNumber = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (name != null && phoneNumber != null) {
                  final newCustomer = Customer(
                    id: DateTime.now().toString(),
                    name: name!,
                    phoneNumber: phoneNumber!,
                    createdAt: DateTime.now(),
                    interestedProperties: [],
                  );
                  Provider.of<CalendarService>(context, listen: false)
                      .addCustomer(newCustomer);
                  Navigator.of(context).pop(newCustomer);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                  );
                }
              },
              child: const Text(
                '추가',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Property?> _selectProperty(
      BuildContext context, List<Property> properties) async {
    return await showDialog<Property>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '매물 선택',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: properties.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_work, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('등록된 매물이 없습니다.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading:
                              const Icon(Icons.home, color: AppColors.primary),
                          title: Text(property.name),
                          subtitle: Text(property.address ?? '주소 없음'),
                          onTap: () => Navigator.of(context).pop(property),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<EventType?> _selectEventType(BuildContext context) async {
    return await showDialog<EventType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '이벤트 유형 선택',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          children: [
            _buildEventTypeOption(
              context,
              EventType.HouseIntroduction,
              '집 소개',
              Icons.home,
            ),
            _buildEventTypeOption(
              context,
              EventType.PreContract,
              '가계약',
              Icons.description,
            ),
            _buildEventTypeOption(
              context,
              EventType.PaymentDate,
              '잔금일',
              Icons.payment,
            ),
            _buildEventTypeOption(
              context,
              EventType.MoveInDate,
              '입주일',
              Icons.moving,
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventTypeOption(
    BuildContext context,
    EventType type,
    String label,
    IconData icon,
  ) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    CalendarService calendarService,
    Event event,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              calendarService.deleteEvent(event);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
