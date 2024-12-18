// lib/services/property_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:image/image.dart' as img;
import 'dart:async'; // StreamSubscription을 위한 import 추가
import 'package:firebase_auth/firebase_auth.dart';

class PropertyService extends ChangeNotifier {
  final CollectionReference _propertyCollection =
      FirebaseFirestore.instance.collection('properties');
  StreamSubscription<QuerySnapshot>? _propertySubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PropertyService() {
    _init();
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return await InternetConnectionChecker().hasConnection;
  }

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();

      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        _error = '인터넷 연결을 확인해주세요';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _fetchProperties();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProperties() async {
    await _propertySubscription?.cancel();

    final user = _auth.currentUser;
    if (user == null) return;

    _propertySubscription = _propertyCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _properties = snapshot.docs.map((doc) {
          return Property.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addProperty(Property property) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('로그인이 필요합니다');

      final propertyData = property.toMap();
      propertyData['userId'] = user.uid;

      await _propertyCollection.add(propertyData);
      notifyListeners();
    } catch (e) {
      print('addProperty 오류: $e');
      rethrow;
    }
  }

  Future<bool> _checkPropertyPermission(String propertyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _propertyCollection.doc(propertyId).get();
    return doc.exists && doc.get('userId') == user.uid;
  }

  Future<void> updateProperty(Property property) async {
    try {
      if (!await _checkPropertyPermission(property.id)) {
        throw Exception('수정 권한이 없습니다');
      }
      await _propertyCollection.doc(property.id).update(property.toMap());
      notifyListeners();
    } catch (e) {
      print('updateProperty 오류: $e');
      rethrow;
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      if (!await _checkPropertyPermission(id)) {
        throw Exception('삭제 권한이 없습니다');
      }
      await _propertyCollection.doc(id).delete();
      notifyListeners();
    } catch (e) {
      print('deleteProperty 오류: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      // 이미지 압축
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('이미지를 디코딩할 수 없습니다.');

      // 이미지 크기 조정 (최대 1000px)
      final resized = img.copyResize(
        image,
        width: image.width > 1000 ? 1000 : image.width,
        height: (image.height * (image.width > 1000 ? 1000 / image.width : 1))
            .toInt(),
      );

      // JPEG로 압축 (품질: 85)
      final compressed = img.encodeJpg(resized, quality: 85);

      // Firebase Storage에 업로드
      String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      // 압축된 이미지 업로드
      await ref.putData(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 오류: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _propertySubscription?.cancel();
    super.dispose();
  }
}
