import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'token_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자 상태 스트림
  Stream<User?> get user => _auth.authStateChanges();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 사용자 역할 가져오기
  Future<String> getUserRole(String uid) async {
    try {
      if (!await checkConnectivity()) {
        print('오프라인 상태 감지 - 기본 권한으로 진행');
        return 'user';
      }

      final token = await TokenService.getToken();
      if (token == null) return 'user';

      final response = await http.get(
        Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.getUserRoleEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print('사용자 역할 조회 오류: $e');
      return 'user';
    }
  }

  // 네트워크 연결 상태 확인 함수 개선
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
