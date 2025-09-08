import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../data/game_data.dart';
import '../widgets/character_detail_dialog.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({Key? key}) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  static const int maxYeastPower = 100;
  static const int yeastRegenRate = 2; // パワー回復量（秒間）
  
  int currentYeastPower = 0;
  Timer? _yeastTimer;
  List<Character> availableCharacters = [];

  @override
  void initState() {
    super.initState();
    availableCharacters = GameData.getAllCharacters();
    _startYeastGeneration();
  }

  @override
  void dispose() {
    _yeastTimer?.cancel();
    super.dispose();
  }

  void _startYeastGeneration() {
    _yeastTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentYeastPower < maxYeastPower) {
        setState(() {
          currentYeastPower = (currentYeastPower + yeastRegenRate).clamp(0, maxYeastPower);
        });
      }
    });
  }

  void _deployCharacter(Character character) {
    if (currentYeastPower >= character.powerCost) {
      setState(() {
        currentYeastPower -= character.powerCost;
      });
      
      // キャラクター配置のロジックをここに追加
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${character.name}を配置しました！'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  bool _canDeployCharacter(Character character) {
    return currentYeastPower >= character.powerCost;
  }

  void _showCharacterDetail(Character character) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CharacterDetailDialog(character: character);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[50],
      appBar: AppBar(
        title: const Text(
          'パン屋大戦争',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[600],
        elevation: 0,
      ),
      body: Column(
        children: [
          // イーストパワー表示部分
          _buildYeastPowerBar(),
          
          // 戦闘エリア
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[100]!,
                    Colors.green[100]!,
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  '戦闘エリア\n（今後実装予定）',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // キャラクター選択部分
          _buildCharacterSelection(),
        ],
      ),
    );
  }

  Widget _buildYeastPowerBar() {
    double powerPercentage = currentYeastPower / maxYeastPower;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[100],
        border: Border(
          bottom: BorderSide(color: Colors.brown[300]!, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'イーストパワー',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$currentYeastPower / $maxYeastPower',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown[600]!, width: 2),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.brown[200],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: powerPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow[400]!,
                          Colors.orange[400]!,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelection() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown[200],
        border: Border(
          top: BorderSide(color: Colors.brown[400]!, width: 2),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableCharacters.length,
        itemBuilder: (context, index) {
          final character = availableCharacters[index];
          final canDeploy = _canDeployCharacter(character);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildCharacterButton(character, canDeploy),
          );
        },
      ),
    );
  }

  Widget _buildCharacterButton(Character character, bool canDeploy) {
    return GestureDetector(
      onTap: canDeploy ? () => _deployCharacter(character) : null,
      onLongPress: () => _showCharacterDetail(character),
      child: Opacity(
        opacity: canDeploy ? 1.0 : 0.5,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: canDeploy ? Colors.white : Colors.grey[300],
            border: Border.all(
              color: canDeploy ? Colors.brown[600]! : Colors.grey[400]!,
              width: 2,
            ),
            boxShadow: canDeploy ? [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // キャラクターアイコン（今後画像に置き換え可能）
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canDeploy ? Colors.orange[300] : Colors.grey[400],
                ),
                child: Icon(
                  Icons.restaurant,
                  color: canDeploy ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              
              // キャラクター名
              Text(
                character.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: canDeploy ? Colors.brown[800] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // パワーコスト表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: canDeploy ? Colors.yellow[400] : Colors.grey[400],
                ),
                child: Text(
                  '${character.powerCost}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: canDeploy ? Colors.brown[800] : Colors.grey[600],
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
