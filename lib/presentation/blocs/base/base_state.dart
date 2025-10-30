import 'package:equatable/equatable.dart';

/// Base state class with common functionality
abstract class BaseState extends Equatable {
  const BaseState();
  
  @override
  List<Object?> get props => [];
}

/// Generic loading state
class LoadingState extends BaseState {
  final String? message;
  
  const LoadingState([this.message]);
  
  @override
  List<Object?> get props => [message];
}

/// Generic error state
class ErrorState extends BaseState {
  final String message;
  final String? code;
  final dynamic error;
  
  const ErrorState(this.message, {this.code, this.error});
  
  @override
  List<Object?> get props => [message, code, error];
}

/// Generic success state
class SuccessState extends BaseState {
  final String? message;
  
  const SuccessState([this.message]);
  
  @override
  List<Object?> get props => [message];
}

/// Generic data state
class DataState<T> extends BaseState {
  final T data;
  final bool isLoading;
  final String? error;
  
  const DataState({
    required this.data,
    this.isLoading = false,
    this.error,
  });
  
  DataState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
  }) {
    return DataState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  @override
  List<Object?> get props => [data, isLoading, error];
}

/// Paginated data state
class PaginatedDataState<T> extends BaseState {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  
  const PaginatedDataState({
    required this.items,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
  });
  
  PaginatedDataState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
  }) {
    return PaginatedDataState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
  
  @override
  List<Object?> get props => [
    items,
    hasMore,
    isLoading,
    isLoadingMore,
    error,
    currentPage,
  ];
}