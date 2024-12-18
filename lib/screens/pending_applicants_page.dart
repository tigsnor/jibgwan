import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/token_service.dart';

class PendingApplicantsPage extends StatelessWidget {
  const PendingApplicantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입 관리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_users')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('대기 중인 회원가입 신청이 없습니다.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(user['realEstateName'] ?? '부동산 없음'),
                subtitle: Text(user['email'] ?? '이메일 없음'),
                trailing: Text(user['status'] ?? 'pending'),
                onTap: () => _showUserDetails(context, users[index].id, user),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserDetails(
      BuildContext context, String userId, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원가입 신청 상세정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('부동산: ${user['realEstateName']}'),
            Text('이메일: ${user['email']}'),
            Text('이름: ${user['name']}'),
            Text('사업자등록번호: ${user['businessRegistrationNumber']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => _rejectUser(context, userId),
            child: const Text('거절', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => _approveUser(context, userId, user),
            child: const Text('승인', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _approveUser(
      BuildContext context, String userId, Map<String, dynamic> user) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.approveUserEndpoint),
        body: json.encode({
          'userId': userId,
          'email': user['email'],
          'password': user['password'],
          'name': user['name'],
          'realEstateName': user['realEstateName'],
          'businessRegistrationNumber': user['businessRegistrationNumber'],
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('승인 처리 실패: ${response.body}');
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 승인되었습니다.')),
        );
      }
    } catch (e) {
      print('Approval error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('승인 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(BuildContext context, String userId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.apiBaseUrl + ApiConstants.rejectUserEndpoint),
        body: json.encode({'userId': userId}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('거절 처리 실패: ${response.body}');
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 거절되었습니다. 이메일이 발송되었습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
