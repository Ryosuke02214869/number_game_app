import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/numeron_game.dart';

class Numeron3GamePage extends StatefulWidget {
  const Numeron3GamePage({super.key});

  @override
  State<Numeron3GamePage> createState() => _Numeron3GamePageState();
}

class _Numeron3GamePageState extends State<Numeron3GamePage> {
  // 設定画面の状態
  int _selectedDigitCount = 4;
  bool _allowDuplicates = false;
  bool _isGameStarted = false;

  // ゲームの状態
  Numeron3Game? _game;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  String _errorMessage = '';
  bool _isRuleExpanded = true;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _game = Numeron3Game(
        digitCount: _selectedDigitCount,
        allowDuplicates: _allowDuplicates,
      );
      _controllers = List.generate(
        _selectedDigitCount,
        (_) => TextEditingController(),
      );
      _focusNodes = List.generate(
        _selectedDigitCount,
        (_) => FocusNode(),
      );
      _isGameStarted = true;
    });
  }

  void _submitGuess() {
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

    // 重複チェック（重複なしモードの場合）
    if (!_allowDuplicates && guessDigits.toSet().length != _selectedDigitCount) {
      setState(() {
        _errorMessage = '重複のない数字を入力してください';
      });
      return;
    }

    final result = _game!.makeGuess(guessDigits.cast<int>());

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

    if (_game!.isGameWon()) {
      _showWinDialog();
    } else {
      setState(() {});
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 おめでとうございます！'),
        content: Text('${_game!.attemptCount}回で正解しました！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToSettings();
            },
            child: const Text('設定に戻る'),
          ),
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
      _game!.reset();
      for (var controller in _controllers) {
        controller.clear();
      }
      _errorMessage = '';
    });
    _focusNodes[0].requestFocus();
  }

  void _resetToSettings() {
    setState(() {
      _isGameStarted = false;
      _game = null;
      for (var controller in _controllers) {
        controller.dispose();
      }
      for (var focusNode in _focusNodes) {
        focusNode.dispose();
      }
      _controllers = [];
      _focusNodes = [];
      _errorMessage = '';
    });
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
        title: const Text('ヌメロン3'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isGameStarted)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _resetToSettings,
              tooltip: '設定に戻る',
            ),
          if (_isGameStarted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
              tooltip: 'リセット',
            ),
        ],
      ),
      body: _isGameStarted ? _buildGameScreen() : _buildSettingsScreen(),
    );
  }

  Widget _buildSettingsScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.settings,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'ゲーム設定',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '桁数',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [4, 5, 6, 7, 8].map((count) {
                        return ChoiceChip(
                          label: Text('$count桁'),
                          selected: _selectedDigitCount == count,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDigitCount = count;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '重複',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('重複を許可する'),
                      subtitle: Text(
                        _allowDuplicates
                            ? '同じ数字が複数回使われます'
                            : '同じ数字は1回のみ使われます',
                      ),
                      value: _allowDuplicates,
                      onChanged: (value) {
                        setState(() {
                          _allowDuplicates = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'ゲーム開始',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    if (_game == null) return const SizedBox();

    return Padding(
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
                    '試行回数: ${_game!.attemptCount}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$_selectedDigitCount桁 ${_allowDuplicates ? '重複あり' : '重複なし'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
                    child: Text(
                      '${_allowDuplicates ? '重複ありの' : '重複のない'}$_selectedDigitCount桁の数字を当ててください\n'
                      '緑色: 位置と数字が一致（HIT）\n'
                      '黄色: 数字は一致するが位置が異なる（BITE）\n'
                      'グレー: 含まれない',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_selectedDigitCount, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < _selectedDigitCount - 1) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                      onSubmitted: (_) {
                        if (index == _selectedDigitCount - 1) {
                          _submitGuess();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
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
          ElevatedButton(
            onPressed: _submitGuess,
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
            child: _game!.history.isEmpty
                ? const Center(
                    child: Text(
                      'まだ予想がありません\n数字を入力して始めましょう！',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _game!.history.length,
                    itemBuilder: (context, index) {
                      final historyIndex = _game!.history.length - 1 - index;
                      final result = _game!.history[historyIndex];
                      final isWinning = result.hit == _selectedDigitCount;
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(_selectedDigitCount, (digitIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                        child: _buildDigitBox(
                                          digits[digitIndex],
                                          result.digitStatuses[digitIndex],
                                          size: 40,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
    );
  }
}
