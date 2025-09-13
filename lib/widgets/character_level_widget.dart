import 'package:flutter/material.dart';
import '../services/character_level_service.dart';

class CharacterLevelWidget extends StatefulWidget {
  final String characterName;
  final bool showProgressBar;
  final double? width;
  final double? height;
  final bool isCompact; // コンパクト表示（ガチャ用）
  final bool animateProgress; // プログレス変化をアニメーション

  const CharacterLevelWidget({
    super.key,
    required this.characterName,
    this.showProgressBar = true,
    this.width,
    this.height,
    this.isCompact = false,
    this.animateProgress = false,
  });

  @override
  State<CharacterLevelWidget> createState() => _CharacterLevelWidgetState();
}

class _CharacterLevelWidgetState extends State<CharacterLevelWidget>
    with TickerProviderStateMixin {
  int level = 1;
  int currentCards = 0;
  int requiredCards = 2;
  double progress = 0.0;
  double _animatedProgress = 0.0;
  
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _progressAnimation.addListener(() {
      setState(() {
        _animatedProgress = _progressAnimation.value * progress;
      });
    });
    
    _loadCharacterProgress();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacterProgress() async {
    final progressData = await CharacterLevelService.getCharacterProgress(widget.characterName);
    
    if (mounted) {
      final oldProgress = progress;
      setState(() {
        level = progressData['level'];
        currentCards = progressData['currentCards'];
        requiredCards = progressData['requiredCards'];
        progress = progressData['progress'];
        _animatedProgress = widget.animateProgress ? oldProgress : progress;
      });
      
      // プログレス変化をアニメーション
      if (widget.animateProgress && oldProgress != progress) {
        _progressAnimationController.reset();
        _progressAnimation = Tween<double>(
          begin: oldProgress,
          end: progress,
        ).animate(CurvedAnimation(
          parent: _progressAnimationController,
          curve: Curves.easeOutCubic,
        ));
        
        _progressAnimation.addListener(() {
          setState(() {
            _animatedProgress = _progressAnimation.value;
          });
        });
        
        _progressAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactWidget();
    } else {
      return _buildFullWidget();
    }
  }

  Widget _buildCompactWidget() {
    return Container(
      width: widget.width ?? 75,
      height: widget.height ?? 28, // 高さを増加
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // パディングを増加
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 要素間にスペースを確保
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // レベル表示
          Text(
            'Lv.$level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          // プログレスバー
          if (widget.showProgressBar) ...[
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (widget.animateProgress ? _animatedProgress : progress).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getProgressColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullWidget() {
    return Container(
      width: widget.width ?? 150,
      height: widget.height ?? 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // レベル表示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'レベル $level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentCards/$requiredCards',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // プログレスバー
          if (widget.showProgressBar) ...[
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (widget.animateProgress ? _animatedProgress : progress).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getProgressColor(),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: _getProgressColor().withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '次のレベルまで: ${requiredCards - currentCards}枚',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (progress >= 0.8) return Colors.orange;
    if (progress >= 0.5) return Colors.yellow;
    if (progress >= 0.3) return Colors.lightBlue;
    return Colors.green;
  }

  // 外部からプログレスを更新するメソッド
  Future<void> refreshProgress() async {
    await _loadCharacterProgress();
  }
}

// レベルアップエフェクト用のウィジェット
class LevelUpEffectWidget extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onAnimationComplete;

  const LevelUpEffectWidget({
    super.key,
    required this.newLevel,
    this.onAnimationComplete,
  });

  @override
  State<LevelUpEffectWidget> createState() => _LevelUpEffectWidgetState();
}

class _LevelUpEffectWidgetState extends State<LevelUpEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.7, 1.0),
    ));

    // アニメーション開始
    _scaleController.forward();
    _fadeController.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.withOpacity(0.9),
                    Colors.orange.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 レベルアップ! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'レベル ${widget.newLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
