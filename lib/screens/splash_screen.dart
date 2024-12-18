import 'package:flutter/material.dart';
import 'package:jibgwan/constants/colors.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jibgwan/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const MainScaffold() : const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Icon(
                  Icons.real_estate_agent_sharp,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              // 슬로건
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        '내 부동산 집 관리를 쉽게',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black87,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '집관',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 2.0,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
