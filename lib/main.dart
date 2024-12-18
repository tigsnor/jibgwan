import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 추가된 임포트
import 'package:jibgwan/constants/colors.dart';
import 'package:jibgwan/firebase_options.dart';
import 'package:jibgwan/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'services/calendar_service.dart';
import 'services/property_service.dart';
import 'services/auth_service.dart';
import 'theme.dart';
import 'screens/admin_main_page.dart';
import 'screens/calendar_page.dart';
import 'screens/settings_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart'; // SignupPage 임포트 추가
import 'screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  // 반드시 가장 먼저 호출
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // SharedPreferences 초기화 - try-catch로 감싸기
    final prefs = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('SharedPreferences initialization timed out');
      },
    );
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PropertyService()),
          ChangeNotifierProvider(create: (_) => CalendarService()),
          Provider(create: (_) => AuthService()),
          StreamProvider<User?>(
            create: (context) => context.read<AuthService>().authStateChanges(),
            initialData: null,
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    // 에러 발생 시 기본값으로 시작
    runApp(
      MaterialApp(
        home: const SplashScreen(),
        theme: AppTheme.themeData,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집관',
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/main': (context) => const MainScaffold(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/main':
            return MaterialPageRoute(
              builder: (context) => const MainScaffold(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}

// 기존의 _JipGwanAppState 클래스를 MainScaffold로 변경
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;

  static final List<Widget> _pages = <Widget>[
    const CalendarPage(),
    const AdminMainPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
