import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/numeron_game.dart';

class Numeron4GamePage extends StatefulWidget {
  const Numeron4GamePage({super.key});

  @override
  State<Numeron4GamePage> createState() => _Numeron4GamePageState();
}

class _Numeron4GamePageState extends State<Numeron4GamePage> {
  final Numeron4Game _game = Numeron4Game();
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );
  String _errorMessage = '';
  bool _isRuleExpanded = true;

  // タイマー関連
  static const int _totalSeconds = 30;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isGameOver = true;
          _showTimeUpDialog();
        }
      });
    });
  }

  void _submitGuess() {
    if (_isGameOver) return;

    setState(() {
      _errorMessage = '';
    });

    // すべての入力が埋まっているかチェック
    if (_controllers.any((controller) => controller.text.isEmpty)) {
      setState(() {
        _errorMessage = 'すべての桁を入力してください';
      });
      return;
    }

    final guessDigits = _controllers
        .map((controller) => int.tryParse(controller.text))
        .toList();

    // すべて数字かチェック
    if (guessDigits.any((digit) => digit == null)) {
      setState(() {
        _errorMessage = '数字のみを入力してください';
      });
      return;
    }

    // 重複チェック
    if (guessDigits.toSet().length != 4) {
      setState(() {
        _errorMessage = '重複のない数字を入力してください';
      });
      return;
    }

    final result = _game.makeGuess(guessDigits.cast<int>());

    if (result == null) {
      setState(() {
        _errorMessage = '無効な入力です';
      });
      return;
    }

    // 入力フィールドをクリア
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    if (_game.isGameWon()) {
      _timer?.cancel();
      _isGameOver = true;
      _showWinDialog();
    } else {
      setState(() {});
    }
  }

  void _showWinDialog() {
    final elapsedTime = _totalSeconds - _remainingSeconds;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 おめでとうございます！'),
        content: Text(
          '${_game.attemptCount}回で正解しました！\n'
          '経過時間: $elapsedTime秒',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('もう一度'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ゲーム選択に戻る'),
          ),
        ],
      ),
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏰ 時間切れ！'),
        content: Text('${_game.attemptCount}回挑戦しました'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('もう一度'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ゲーム選択に戻る'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _game.reset();
      for (var controller in _controllers) {
        controller.clear();
      }
      _errorMessage = '';
      _remainingSeconds = _totalSeconds;
      _isGameOver = false;
    });
    _focusNodes[0].requestFocus();
    _startTimer();
  }

  Color _getColorForStatus(DigitStatus status) {
    switch (status) {
      case DigitStatus.hit:
        return Colors.green;
      case DigitStatus.bite:
        return Colors.yellow.shade700;
      case DigitStatus.none:
        return Colors.grey.shade300;
    }
  }

  Color _getTimerColor() {
    final percentage = _remainingSeconds / _totalSeconds;
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildDigitBox(String digit, DigitStatus status, {double size = 50}) {
    final color = _getColorForStatus(status);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヌメロン4 - タイムアタック'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'リセット',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 試行回数表示（常に表示）
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.numbers, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '試行回数: ${_game.attemptCount}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ルール説明（折りたたみ可能）
            Card(
              elevation: 2,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isRuleExpanded = !_isRuleExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ルール説明',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _isRuleExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isRuleExpanded)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: const Text(
                        '30秒以内に重複のない4桁の数字を当ててください\n'
                        '緑色: 位置と数字が一致（HIT）\n'
                        '黄色: 数字は一致するが位置が異なる（BITE）\n'
                        'グレー: 含まれない',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '数字を入力',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    enabled: !_isGameOver,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                    onSubmitted: (_) {
                      if (index == 3) {
                        _submitGuess();
                      }
                    },
                  ),
                );
              }),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            // 制限時間インジケーター
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '残り時間',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_remainingSeconds秒',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getTimerColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _remainingSeconds / _totalSeconds,
                    minHeight: 20,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGameOver ? null : _submitGuess,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                '決定',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '履歴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _game.history.isEmpty
                  ? const Center(
                      child: Text(
                        'まだ予想がありません\n数字を入力して始めましょう！',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _game.history.length,
                      itemBuilder: (context, index) {
                        final historyIndex = _game.history.length - 1 - index;
                        final result = _game.history[historyIndex];
                        final isWinning = result.hit == 4;
                        final digits = result.guess.split('');

                        return Card(
                          color: isWinning ? Colors.green[50] : null,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isWinning
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    '${historyIndex + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(4, (digitIndex) {
                                      return _buildDigitBox(
                                        digits[digitIndex],
                                        result.digitStatuses[digitIndex],
                                        size: 50,
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HIT: ${result.hit}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'BITE: ${result.bite}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
