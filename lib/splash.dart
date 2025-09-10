import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _opacity = 1.0;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'ANZAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 800),
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}