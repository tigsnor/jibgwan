import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'pending_applicants_page.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_management_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/token_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return FutureBuilder<String>(
      future: user != null
          ? AuthService().getUserRole(user.uid)
          : Future.value('user'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('사용자 정보를 불러오는 중...'),
                ],
              ),
            ),
          );
        }

        // 에러가 발생하나 데이터가 없으면 기본 사용자 권한 사용
        final role =
            snapshot.hasError || !snapshot.hasData ? 'user' : snapshot.data!;

        if (snapshot.hasError) {
          print('역할 조회 오류: ${snapshot.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사용자 정보를 불러오는데 실패했습니다. 기본 권한으로 접속합��다.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('설정'),
            elevation: 0,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 16),
              // 프로필 섹션
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.email ?? '사용자',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role == 'admin' ? '관리자' : '일반 사용자',
                      style: TextStyle(
                        color: role == 'admin' ? AppColors.accent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 설정 메뉴들
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      title: const Text('프로필 편집'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // 프로필 편집 페이지로 이동
                      },
                    ),
                    if (role == 'admin') ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.people_outline,
                            color: AppColors.accent),
                        title: const Text('가입 신청자 목록'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PendingApplicantsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () async {
                        await _logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('로그아웃 실패: ${response.body}');
      }

      // 토큰 삭제
      await TokenService.removeToken();

      // SharedPreferences에서 로그인 상태 삭제
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }
}
