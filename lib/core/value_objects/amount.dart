class Amount {
  final double value;
  
  const Amount(this.value);
  
  factory Amount.zero() => const Amount(0.0);
  
  factory Amount.fromString(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw ArgumentError('Invalid amount format: $value');
    }
    return Amount(parsed);
  }
  
  bool get isPositive => value > 0;
  bool get isNegative => value < 0;
  bool get isZero => value == 0;
  
  Amount operator +(Amount other) => Amount(value + other.value);
  Amount operator -(Amount other) => Amount(value - other.value);
  Amount operator *(double multiplier) => Amount(value * multiplier);
  Amount operator /(double divisor) => Amount(value / divisor);
  
  bool operator >(Amount other) => value > other.value;
  bool operator <(Amount other) => value < other.value;
  bool operator >=(Amount other) => value >= other.value;
  bool operator <=(Amount other) => value <= other.value;
  
  Amount abs() => Amount(value.abs());
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Amount && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => value.toStringAsFixed(2);
}