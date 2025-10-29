import 'package:penpenny/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}