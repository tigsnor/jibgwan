# 코드 리스크 점검 리포트

아래 항목은 실제 동작 오류 가능성/보안 리스크가 높은 순서로 정리했습니다.

## 1) Cloud Functions가 중복 초기화되어 배포/실행 오류 가능
- `functions/src/index.ts`에서 `admin.initializeApp()`을 호출하고, `functions/src/auth.ts`에서도 다시 `admin.initializeApp()`을 호출합니다.
- Firebase Admin SDK는 일반적으로 한 번만 초기화해야 하므로, 현재 구조는 `The default Firebase app already exists` 류의 런타임 오류를 유발할 수 있습니다.
- 권장: 초기화는 엔트리포인트 한 곳(`index.ts`)에서만 수행하고, 하위 모듈에서는 `admin.app()`/`admin.firestore()`만 사용.

## 2) 서버 로그인 로직이 Firebase Auth 구조와 맞지 않아 인증 실패 가능
- `functions/src/auth.ts`의 `login` 함수는 `admin.auth().getUserByEmail()` 결과에서 `passwordHash`를 꺼내 `bcrypt.compare()`로 검증합니다.
- Firebase Auth(관리 SDK)에서는 일반 앱 비밀번호를 이렇게 검증하는 경로가 보장되지 않으며, 환경에 따라 `passwordHash`가 없거나 포맷이 달라 실패할 가능성이 큽니다.
- 권장: 클라이언트 SDK의 `signInWithEmailAndPassword`를 사용하거나, 서버에서 검증이 필요하면 Firebase Auth의 공식 인증 플로우 기반으로 재설계.

## 3) 승인(approve) 로직이 해시 비밀번호와 평문 비밀번호를 혼용
- `signup` 시점에는 `pending_users`에 `bcrypt.hash(password, 10)`으로 저장합니다.
- 하지만 `approveUser`는 요청 바디의 `password`를 그대로 `createUser({ password })`에 전달합니다.
- 즉, 저장된 해시를 쓰는 구조가 아니며, 승인 호출자가 평문을 다시 보내야만 계정 생성이 가능한 불일치가 존재합니다.
- 권장: 승인 시 평문 재입력을 없애고, 계정 생성 시점/절차를 재설계(예: 승인 후 초기 비밀번호 설정 링크).

## 4) 클라이언트 API Base URL이 플레이스홀더 상태
- `lib/constants/api_constants.dart`의 `apiBaseUrl`이 `https://your-firebase-function-url.com`으로 남아 있습니다.
- 실제 배포 URL 미설정 시 로그인/회원가입/역할조회 API가 전부 실패합니다.
- 권장: 빌드 환경(dev/stage/prod)별 실제 URL 주입(예: `--dart-define`, flavor, env 파일).

## 5) 로그인 상태 판정이 `SharedPreferences` 불리언에만 의존
- `lib/screens/splash_screen.dart`는 `isLoggedIn` 값만 보고 메인 화면으로 이동합니다.
- 토큰 만료/위조/삭제와 무관하게 로컬 값만 참이면 진입할 수 있어 상태 불일치 가능성이 큽니다.
- 권장: 앱 시작 시 토큰 존재 + 유효성(또는 Firebase 현재 세션) 확인으로 게이트를 구성.

## 6) 민감정보 저장소 선택 리스크
- `lib/services/token_service.dart`는 인증 토큰을 `SharedPreferences`에 저장합니다.
- 일반적으로 `SharedPreferences`는 보안 저장소가 아니므로 탈옥/루팅/디버깅 환경에서 노출 리스크가 있습니다.
- 권장: `flutter_secure_storage` 등 OS 보안 저장소 사용.

## 7) 사용되지 않는 보안 코드로 인한 혼선
- `lib/screens/signup_page.dart`에 `_hashPassword()`가 구현되어 있지만 실제 전송 시 사용되지 않습니다.
- 보안처리 책임 위치(클라이언트/서버)가 코드상 모호해져 유지보수 시 실수 가능성이 큽니다.
- 권장: 미사용 코드 제거 후, 비밀번호 처리는 서버 책임으로 일원화.

---

## 빠른 우선순위 제안
1. **즉시**: Admin 중복 초기화 제거 + 로그인 인증 플로우 재구성.
2. **단기**: approve/sign-up 비밀번호 처리 절차 일관화.
3. **단기**: API base URL 환경 분리 및 주입.
4. **중기**: 토큰 저장소 보안 강화 + 스플래시 인증 게이트 개선.
