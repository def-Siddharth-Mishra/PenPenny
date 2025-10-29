part of 'categories_bloc.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  CategoriesLoaded(this.categories);
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}