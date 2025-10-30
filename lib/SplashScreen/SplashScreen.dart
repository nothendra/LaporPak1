import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../OnBoarding/OnBoarding.dart';
import 'package:flutter_application_1/services/auth_provider.dart';

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

    // Animasi muncul halus (fade + slide)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Setelah beberapa detik, arahkan berdasarkan status login
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        final role = auth.userRole;
        if (role == 'rt') {
          Navigator.pushReplacementNamed(context, '/rt_home');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/home_admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, _, child) {
              final tween = Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            pageBuilder: (context, _, __) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔄 Ganti Icon jadi Logo Gambar
                Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset('assets/logo2.png', fit: BoxFit.contain),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Text(
                  "Lapor Pak",
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.deepPurple.shade700,
                  ),
                ),

                // Subjudul
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: 10,
                  ),
                  child: Text(
                    "Bersama Peduli Membawa Perubahan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Loading indicator halus
                const CircularProgressIndicator(
                  color: Colors.deepPurple,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
