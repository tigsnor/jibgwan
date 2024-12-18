// lib/screens/admin_main_page.dart

import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:jibgwan/models/property.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../widgets/property_card.dart';
import 'create_property_page.dart';
import '../constants/colors.dart'; // 색상 상수 임포트
import 'package:file_picker/file_picker.dart';
// import 'package:excel/excel.dart';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:flutter/foundation.dart';
import '../widgets/bottom_nav_bar.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AdminMainPage extends StatelessWidget {
  const AdminMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return FutureBuilder<String>(
      future:
          user != null ? AuthService().getUserRole(user.uid) : Future.value(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data != 'admin') {
          return const Center(
            child: Text('권한이 없거나 오류가 발생했습니다.'),
          );
        }

        // 권한 확인 후 매물 목록 표시
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('properties')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
            }

            // 여기에 기존 매물 목록 UI 코드
            return Scaffold(
              appBar: AppBar(
                title: const Text('매물 관리'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // 필터 기능 구현
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePropertyPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Consumer<PropertyService>(
                builder: (context, propertyService, child) {
                  if (propertyService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (propertyService.error != null) {
                    return Center(child: Text(propertyService.error!));
                  }

                  final properties = propertyService.properties;

                  return properties.isEmpty
                      ? const Center(child: Text('등록된 매물이 없습니다.'))
                      : ListView.builder(
                          itemCount: properties.length,
                          itemBuilder: (context, index) {
                            return PropertyCard(property: properties[index]);
                          },
                        );
                },
              ),
            );
          },
        );
      },
    );
  }
}

List<Property> processXlsxData(excel.Excel excelFile) {
  List<Property> properties = [];
  // xlsx 처리 로직
  return properties;
}

List<Property> processXlsData(SpreadsheetDecoder decoder) {
  List<Property> properties = [];
  for (var table in decoder.tables.keys) {
    var rows = decoder.tables[table]!.rows;
    // xls 처리 로직
  }
  return properties;
}

Future<List<Property>> processExcelFile(Map<String, dynamic> args) async {
  final bytes = args['bytes'] as List<int>;
  final extension = args['extension'] as String;

  if (extension == 'xlsx') {
    final excelFile = excel.Excel.decodeBytes(bytes);
    return processXlsxData(excelFile);
  } else if (extension == 'xls') {
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    return processXlsData(decoder);
  }
  throw Exception('지원하지 않는 파일 형식입니다');
}
