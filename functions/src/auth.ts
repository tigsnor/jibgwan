import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as bcrypt from 'bcrypt';
import { Request, Response } from 'express';

admin.initializeApp();

export const signup = functions.https.onRequest(async (req: Request, res: Response) => {
  try {
    const { email, password, name, realEstateName, businessRegistrationNumber } = req.body;
    
    // 1. pending_users 컬렉션에 저장
    await admin.firestore().collection('pending_users').add({
      email,
      password: await bcrypt.hash(password, 10),
      name,
      realEstateName,
      businessRegistrationNumber,
      status: 'pending',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ message: '회원가입 신청이 완료되었습니다.' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export const login = functions.https.onRequest(async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    
    // 1. 사용자 확인
    const userRecord = await admin.auth().getUserByEmail(email);
    
    // 2. 비밀번호 검증
    const passwordHash = userRecord.passwordHash;
    if (!passwordHash) {
      throw new Error('Password hash not found');
    }
    
    const isValid = await bcrypt.compare(password, passwordHash);
    
    if (!isValid) {
      throw new Error('Invalid credentials');
    }

    // 3. Custom Token 생성
    const token = await admin.auth().createCustomToken(userRecord.uid);
    
    res.status(200).json({ token });
  } catch (error: any) {
    res.status(401).json({ error: error.message });
  }
});

export const approveUser = functions.https.onRequest(async (req: Request, res: Response) => {
  try {
    const { userId, email, password } = req.body;
    
    // 1. Firebase Auth 계정 생성
    const userRecord = await admin.auth().createUser({
      email,
      password,
    });

    // 2. users 컬렉션에 정보 저장
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email,
      role: 'admin',
      approved: true,
    });

    // 3. pending_users에서 삭제
    await admin.firestore().collection('pending_users').doc(userId).delete();

    res.status(200).json({ message: '사용자가 승인되었습니다.' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}); 