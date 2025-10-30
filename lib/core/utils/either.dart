/// Represents a value that can be either a Left (failure) or Right (success)
abstract class Either<L, R> {
  const Either();
  
  /// Returns true if this is a Left value
  bool get isLeft;
  
  /// Returns true if this is a Right value  
  bool get isRight => !isLeft;
  
  /// Transforms the right value if present
  Either<L, T> map<T>(T Function(R) mapper);
  
  /// Transforms the left value if present
  Either<T, R> mapLeft<T>(T Function(L) mapper);
  
  /// Executes a function based on the value type
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);
  
  /// Returns the right value or throws if left
  R getOrThrow();
  
  /// Returns the right value or a default
  R getOrElse(R defaultValue);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  
  const Left(this.value);
  
  @override
  bool get isLeft => true;
  
  @override
  Either<L, T> map<T>(T Function(R) mapper) => Left(value);
  
  @override
  Either<T, R> mapLeft<T>(T Function(L) mapper) => Left(mapper(value));
  
  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onLeft(value);
  
  @override
  R getOrThrow() => throw Exception('Called getOrThrow on Left: $value');
  
  @override
  R getOrElse(R defaultValue) => defaultValue;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  
  const Right(this.value);
  
  @override
  bool get isLeft => false;
  
  @override
  Either<L, T> map<T>(T Function(R) mapper) => Right(mapper(value));
  
  @override
  Either<T, R> mapLeft<T>(T Function(L) mapper) => Right(value);
  
  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onRight(value);
  
  @override
  R getOrThrow() => value;
  
  @override
  R getOrElse(R defaultValue) => value;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
}