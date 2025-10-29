part of 'categories_bloc.dart';

abstract class CategoriesEvent {}

class LoadCategories extends CategoriesEvent {}

class CreateCategory extends CategoriesEvent {
  final Category category;
  CreateCategory(this.category);
}

class UpdateCategory extends CategoriesEvent {
  final Category category;
  UpdateCategory(this.category);
}

class DeleteCategory extends CategoriesEvent {
  final int categoryId;
  DeleteCategory(this.categoryId);
}