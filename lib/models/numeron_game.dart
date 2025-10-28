import 'dart:math';

enum DigitStatus {
  hit,   // 位置と数字が一致
  bite,  // 数字は含まれるが位置が異なる
  none,  // 含まれない
}

class GameResult {
  final int hit;
  final int bite;
  final String guess;

  GameResult({required this.hit, required this.bite, required this.guess});
}

class DetailedGameResult extends GameResult {
  final List<DigitStatus> digitStatuses;

  DetailedGameResult({
    required super.hit,
    required super.bite,
    required super.guess,
    required this.digitStatuses,
  });
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

class Numeron2Game {
  late List<int> _targetNumber;
  final List<DetailedGameResult> _history = [];
  int _attemptCount = 0;

  Numeron2Game() {
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

  DetailedGameResult? makeGuess(List<int> guessDigits) {
    // 入力の検証
    if (guessDigits.length != 4) {
      return null;
    }

    // 各桁が0-9の範囲かチェック
    if (guessDigits.any((digit) => digit < 0 || digit > 9)) {
      return null;
    }

    // 重複チェック
    if (guessDigits.toSet().length != 4) {
      return null;
    }

    _attemptCount++;

    int hit = 0;
    int bite = 0;
    final List<DigitStatus> digitStatuses = [];

    // 各桁のステータスを計算
    for (int i = 0; i < 4; i++) {
      if (guessDigits[i] == _targetNumber[i]) {
        hit++;
        digitStatuses.add(DigitStatus.hit);
      } else if (_targetNumber.contains(guessDigits[i])) {
        bite++;
        digitStatuses.add(DigitStatus.bite);
      } else {
        digitStatuses.add(DigitStatus.none);
      }
    }

    final result = DetailedGameResult(
      hit: hit,
      bite: bite,
      guess: guessDigits.join(),
      digitStatuses: digitStatuses,
    );
    _history.add(result);

    return result;
  }

  bool isGameWon() {
    return _history.isNotEmpty && _history.last.hit == 4;
  }

  int get attemptCount => _attemptCount;
  List<DetailedGameResult> get history => List.unmodifiable(_history);

  // デバッグ用（実際のゲームでは使用しない）
  String get targetNumberForDebug => _targetNumber.join();
}
