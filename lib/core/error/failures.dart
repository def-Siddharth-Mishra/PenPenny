abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;
  
  const ValidationFailure(super.message, this.errors, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}