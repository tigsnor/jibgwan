import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> _approveUser(
    BuildContext context, String userId, Map<String, dynamic> user) async {
  try {
    // Firebase Auth에 사용자 계정 생성 (회원가입 시 입력한 비밀번호 사용)
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user['email'],
      password: user['password'], // pending_users에 저장된 비밀번호 사용
    );

    // users 컬렉션에 승인된 사용자 정보 추가
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': user['email'],
      'name': user['name'],
      'realEstateName': user['realEstateName'],
      'businessRegistrationNumber': user['businessRegistrationNumber'],
      'role': 'admin',
      'approved': true,
      'uid': userCredential.user!.uid,
    });

    // pending_users에서 해당 문서 삭제
    await FirebaseFirestore.instance
        .collection('pending_users')
        .doc(userId)
        .delete();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 승인되었습니다.')),
      );
    }
  } catch (e) {
    print('Approval error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('승인 처리 중 오류가 발생했습니다: $e')),
    );
  }
}
