import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String name = '';
  String realEstateName = '';
  String businessRegistrationNumber = '';

  // 비밀번호 조건 체크를 위한 상태 변수들
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[0-9])(?=.*[a-z]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // 비밀번호 조건 체크 함수
  void _checkPassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUpperCase = value.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = value.contains(RegExp(r'[a-z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // 비밀번호 입력 필드 위젯
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: '비밀번호',
            prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          controller: _passwordController,
          obscureText: true,
          onChanged: _checkPassword,
          onSaved: (value) => password = value!,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            if (!_isPasswordValid(value)) {
              return '비밀번호 형식이 올바르지 않습니다.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // 비밀번호 조건 체크 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequirement('8자 이상', _hasMinLength),
              _buildRequirement('대문자 포함', _hasUpperCase),
              _buildRequirement('소문자 포함', _hasLowerCase),
              _buildRequirement('숫자 포함', _hasDigit),
              _buildRequirement('특수문자 포함', _hasSpecialChar),
            ],
          ),
        ),
      ],
    );
  }

  // 각 요구사항 아이템 위젯
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이메일',
                  prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(), // 기존 TextFormField 대신 이 위젯 사용
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: AppColors.primary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이름',
                  prefixIcon:
                      const Icon(Icons.person, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '부동산 이름',
                  prefixIcon:
                      const Icon(Icons.business, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => realEstateName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '부동산 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '사업자 등록번호',
                  prefixIcon:
                      const Icon(Icons.numbers, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => businessRegistrationNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '사업자 등록번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitSignup,
                child: const Text(
                  '가입 신청',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitSignup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.signupEndpoint),
          body: json.encode({
            'email': email,
            'password': password,
            'name': name,
            'realEstateName': realEstateName,
            'businessRegistrationNumber': businessRegistrationNumber,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception('회원가입 실패: ${response.body}');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입 신청이 완료되었습니다. 관리자 승인 후 로그인 가능합니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Signup error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 신청 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
