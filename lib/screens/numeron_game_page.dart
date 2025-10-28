import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/numeron_game.dart';

class NumeronGamePage extends StatefulWidget {
  const NumeronGamePage({super.key});

  @override
  State<NumeronGamePage> createState() => _NumeronGamePageState();
}

class _NumeronGamePageState extends State<NumeronGamePage> {
  final NumeronGame _game = NumeronGame();
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';
  bool _isRuleExpanded = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitGuess() {
    setState(() {
      _errorMessage = '';
    });

    final guess = _controller.text;

    if (guess.length != 4) {
      setState(() {
        _errorMessage = '4桁の数字を入力してください';
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(guess)) {
      setState(() {
        _errorMessage = '数字のみを入力してください';
      });
      return;
    }

    if (guess.split('').toSet().length != 4) {
      setState(() {
        _errorMessage = '重複のない数字を入力してください';
      });
      return;
    }

    final result = _game.makeGuess(guess);

    if (result == null) {
      setState(() {
        _errorMessage = '無効な入力です';
      });
      return;
    }

    _controller.clear();

    if (_game.isGameWon()) {
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
        content: Text('${_game.attemptCount}回で正解しました！'),
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
      _controller.clear();
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヌメロン'),
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
                        '重複のない4桁の数字を当ててください\n'
                        'HIT: 位置と数字が一致\n'
                        'BITE: 数字は一致するが位置が異なる',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: '4桁の数字を入力',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage.isEmpty ? null : _errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onSubmitted: (_) => _submitGuess(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitGuess,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    '決定',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
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

                        return Card(
                          color: isWinning ? Colors.green[50] : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isWinning
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              child: Text(
                                '${historyIndex + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              result.guess,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text('HIT: ${result.hit}'),
                                  backgroundColor: Colors.red[100],
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text('BITE: ${result.bite}'),
                                  backgroundColor: Colors.yellow[100],
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
