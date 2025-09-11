import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EndRollScreen extends StatefulWidget {
  final bool isVictory;
  
  const EndRollScreen({super.key, required this.isVictory});

  @override
  State<EndRollScreen> createState() => _EndRollScreenState();
}

class _EndRollScreenState extends State<EndRollScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // ;b��*Mk��
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 20), // 20�g�����
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // ;bK���
      end: const Offset(0.0, -1.0),  // ;b
k�H�
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    // ��������
    _animationController.forward();
    
    // �������Bk���;bk;�
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          // ���g���;bk;�
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: Stack(
          children: [
            // �o
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF001122),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
            
            // ������
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 2, // ;bn2n�U
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    
                    // �W�û��
                    Text(
                      widget.isVictory ? 'Victory!' : 'Game Over',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.isVictory ? Colors.yellow : Colors.red,
                        shadows: const [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // ��࿤��
                    const Text(
                      '�����',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // ����
                    ..._buildCredits(),
                    
                    const SizedBox(height: 80),
                    
                    // �û��
                    const Text(
                      'B�LhFTVD~W_',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.blue,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // ���H�
                    const Text(
                      '���g���;bk;�',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCredits() {
    final credits = [
      _buildCreditSection(';��z', ['Claude Code', '�����']),
      _buildCreditSection('��鯿�Ƕ��', ['Rive �������', '��ƣ���']),
      _buildCreditSection('�}����', ['��-']),
      _buildCreditSection('�����', ['Flutter', 'Flame Engine', 'Dart']),
      _buildCreditSection('y%T�', ['Anthropic', 'Claude AI']),
      _buildCreditSection('(�S', [
        'Flutter Framework',
        'Flame Game Engine', 
        'Rive Animation',
        'Dart Language'
      ]),
    ];
    
    return credits
        .map((section) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: section,
            ))
        .toList();
  }

  Widget _buildCreditSection(String title, List<String> names) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
            shadows: [
              Shadow(
                color: Colors.white,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...names.map((name) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )),
      ],
    );
  }
}