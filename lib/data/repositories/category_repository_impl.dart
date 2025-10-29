import 'package:penpenny/data/datasources/database_helper.dart';
import 'package:penpenny/data/models/category_model.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromJson(maps[i]));
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CategoryModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<Category> createCategory(Category category) async {
    final db = await DatabaseHelper.database;
    final categoryModel = CategoryModel.fromEntity(category);
    final id = await db.insert('categories', categoryModel.toJson());
    return categoryModel.copyWith(id: id);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final db = await DatabaseHelper.database;
    final categoryModel = CategoryModel.fromEntity(category);
    await db.update(
      'categories',
      categoryModel.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return category;
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}