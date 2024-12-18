import 'package:flutter/material.dart';
import 'package:jibgwan/main.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/token_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // 로고 또는 앱 이름
                  const Icon(
                    Icons.real_estate_agent_sharp,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '집관',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // 이메일 입력
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '이메일',
                      prefixIcon:
                          const Icon(Icons.email, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => email = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 비밀번호 입력
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon:
                          const Icon(Icons.lock, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    obscureText: true,
                    onSaved: (value) => password = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // 로그인 버튼
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await _login();
                    },
                    child: Text(
                      '로그인',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 회원가입 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      '회원가입 신청',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // 로그인 API 호출
        final response = await http.post(
          Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.loginEndpoint),
          body: json.encode({
            'email': email,
            'password': password,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception('로그인 실패: ${response.body}');
        }

        // 응답에서 토큰 추출 및 저장
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        await TokenService.saveToken(token);

        // 로그인 상태 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
