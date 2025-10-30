import 'package:penpenny/core/error/failures.dart';
import 'package:penpenny/core/utils/either.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

abstract class StreamUseCase<T, P> {
  Stream<Either<Failure, T>> call(P params);
}

class NoParams {
  const NoParams();
}

class Params<T> {
  final T data;
  
  const Params(this.data);
}

class PaginationParams {
  final int page;
  final int limit;
  
  const PaginationParams({
    required this.page,
    required this.limit,
  });
}

class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;
  
  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}