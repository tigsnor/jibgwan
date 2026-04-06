import 'package:flutter_test/flutter_test.dart';

import 'package:jibgwan/main.dart';

void main() {
  testWidgets('앱 시작 시 기본 라우트 화면이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 기본 라우트("/")는 SplashScreen이며 브랜드 텍스트를 포함한다.
    expect(find.text('집관'), findsWidgets);
  });
}
