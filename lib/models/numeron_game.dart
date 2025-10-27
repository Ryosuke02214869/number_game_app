import 'dart:math';

class GameResult {
  final int hit;
  final int bite;
  final String guess;

  GameResult({required this.hit, required this.bite, required this.guess});
}

class NumeronGame {
  late List<int> _targetNumber;
  final List<GameResult> _history = [];
  int _attemptCount = 0;

  NumeronGame() {
    reset();
  }

  void reset() {
    _targetNumber = _generateRandomNumber();
    _history.clear();
    _attemptCount = 0;
  }

  List<int> _generateRandomNumber() {
    final random = Random();
    final Set<int> digits = {};

    // 重複なしの4桁の数字を生成
    while (digits.length < 4) {
      digits.add(random.nextInt(10));
    }

    return digits.toList();
  }

  GameResult? makeGuess(String guess) {
    // 入力の検証
    if (guess.length != 4) {
      return null;
    }

    // 数字のみかチェック
    if (!RegExp(r'^[0-9]+$').hasMatch(guess)) {
      return null;
    }

    // 重複チェック
    if (guess.split('').toSet().length != 4) {
      return null;
    }

    _attemptCount++;

    final guessDigits = guess.split('').map((e) => int.parse(e)).toList();
    int hit = 0;
    int bite = 0;

    // HITとBITEを計算
    for (int i = 0; i < 4; i++) {
      if (guessDigits[i] == _targetNumber[i]) {
        hit++;
      } else if (_targetNumber.contains(guessDigits[i])) {
        bite++;
      }
    }

    final result = GameResult(hit: hit, bite: bite, guess: guess);
    _history.add(result);

    return result;
  }

  bool isGameWon() {
    return _history.isNotEmpty && _history.last.hit == 4;
  }

  int get attemptCount => _attemptCount;
  List<GameResult> get history => List.unmodifiable(_history);

  // デバッグ用（実際のゲームでは使用しない）
  String get targetNumberForDebug => _targetNumber.join();
}
