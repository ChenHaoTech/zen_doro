import 'dart:math';

class NonRepeatingRandomGenerator {
  final List<int> _usedNumbers;
  final Random _random = Random();

  NonRepeatingRandomGenerator({
    List<int> usedNumbers = const [],
  }) : _usedNumbers = usedNumbers.toList(growable: true);

  T? random<T>(List<T> list) {
    if (list.isEmpty) {
      return null;
    }
    var idx = nextInt(max: list.length - 1);
    if (idx == null) return null;
    return list[idx];
  }

  int? nextInt({
    int? min,
    required int max,
  }) {
    if (min != null) {
      if (min > max) {
        throw ArgumentError('Invalid range: min must be less than or equal to max.');
      }
    }
    min = min ?? 0;
    if (_usedNumbers.length == max - min + 1) {
      return null;
    }

    while (true) {
      int randomNumber = min + _random.nextInt(max - min + 1);
      if (!_usedNumbers.contains(randomNumber)) {
        _usedNumbers.add(randomNumber);
        return randomNumber;
      }
    }
  }
}
