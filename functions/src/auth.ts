import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {Request, Response} from "express";

const getErrorMessage = (error: unknown): string => {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
};

const getBearerToken = (authHeader?: string): string | null => {
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.replace("Bearer ", "").trim();
};

type AuthContext = {
  uid: string;
  role: string;
};

const getAuthContext = async (
  req: Request,
  res: Response,
): Promise<AuthContext | null> => {
  const token = getBearerToken(req.headers.authorization);
  if (!token) {
    res.status(401).json({error: "Authorization token is required"});
    return null;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(decodedToken.uid)
      .get();
    const role = userDoc.data()?.role ?? "user";
    return {uid: decodedToken.uid, role};
  } catch (error: unknown) {
    res.status(401).json({error: getErrorMessage(error)});
    return null;
  }
};

export const signup = functions.https.onRequest(async (
  req: Request,
  res: Response,
) => {
  try {
    const {email, name, realEstateName, businessRegistrationNumber} = req.body;

    // 1. pending_users 컬렉션에 저장
    await admin.firestore().collection("pending_users").add({
      email,
      // 승인 이전에는 비밀번호를 저장하지 않습니다.
      // 승인 후 Firebase Auth의 비밀번호 재설정 플로우로 최초 비밀번호를 설정합니다.
      name,
      realEstateName,
      businessRegistrationNumber,
      status: "pending",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({message: "회원가입 신청이 완료되었습니다."});
  } catch (error: unknown) {
    res.status(500).json({error: getErrorMessage(error)});
  }
});

export const login = functions.https.onRequest(async (
  _req: Request,
  res: Response,
) => {
  res.status(410).json({
    error: "Deprecated endpoint. Use Firebase Client SDK login.",
  });
});

export const getUserRole = functions.https.onRequest(async (
  req: Request,
  res: Response,
) => {
  const authContext = await getAuthContext(req, res);
  if (!authContext) {
    return;
  }
  res.status(200).json({role: authContext.role});
});

export const approveUser = functions.https.onRequest(async (
  req: Request,
  res: Response,
) => {
  try {
    const authContext = await getAuthContext(req, res);
    if (!authContext) {
      return;
    }
    if (authContext.role != "admin") {
      res.status(403).json({error: "Only admin can approve users"});
      return;
    }

    const {userId} = req.body;
    if (!userId) {
      res.status(400).json({error: "userId is required"});
      return;
    }

    const pendingDoc = await admin.firestore()
      .collection("pending_users")
      .doc(userId)
      .get();
    if (!pendingDoc.exists) {
      res.status(404).json({error: "Pending user not found"});
      return;
    }

    const pendingData = pendingDoc.data();
    const email = pendingData?.email as string | undefined;

    if (!email) {
      res.status(400).json({error: "Pending user email is missing"});
      return;
    }

    // 1. Firebase Auth 계정 생성 (비밀번호는 승인 후 리셋 링크로 설정)
    const userRecord = await admin.auth().createUser({email});
    const passwordResetLink = await admin.auth()
      .generatePasswordResetLink(email);

    // 2. users 컬렉션에 정보 저장
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      email,
      role: "user",
      approved: true,
      approvedBy: authContext.uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. pending_users에서 삭제
    await admin.firestore().collection("pending_users").doc(userId).delete();

    res.status(200).json({
      message: "사용자가 승인되었습니다. 비밀번호 설정 링크를 전달하세요.",
      passwordResetLink,
    });
  } catch (error: unknown) {
    res.status(500).json({error: getErrorMessage(error)});
  }
});

export const rejectUser = functions.https.onRequest(async (
  req: Request,
  res: Response,
) => {
  try {
    const authContext = await getAuthContext(req, res);
    if (!authContext) {
      return;
    }
    if (authContext.role != "admin") {
      res.status(403).json({error: "Only admin can reject users"});
      return;
    }

    const {userId} = req.body;
    if (!userId) {
      res.status(400).json({error: "userId is required"});
      return;
    }

    await admin.firestore().collection("pending_users").doc(userId).delete();
    res.status(200).json({message: "회원가입 신청이 거절되었습니다."});
  } catch (error: unknown) {
    res.status(500).json({error: getErrorMessage(error)});
  }
});

export const logout = functions.https.onRequest(async (
  req: Request,
  res: Response,
) => {
  try {
    const authContext = await getAuthContext(req, res);
    if (!authContext) {
      return;
    }

    await admin.auth().revokeRefreshTokens(authContext.uid);
    res.status(200).json({message: "로그아웃이 완료되었습니다."});
  } catch (error: unknown) {
    res.status(500).json({error: getErrorMessage(error)});
  }
});
