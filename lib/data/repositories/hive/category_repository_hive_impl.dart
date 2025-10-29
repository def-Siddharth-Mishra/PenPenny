import 'package:penpenny/data/models/hive/category_hive_model.dart';
import 'package:penpenny/data/services/hive_service.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';

class CategoryRepositoryHiveImpl implements CategoryRepository {
  @override
  Future<List<Category>> getAllCategories() async {
    final box = HiveService.categoriesBoxInstance;
    final categories = box.values.map((model) => model.toEntity()).toList();
    return categories;
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final box = HiveService.categoriesBoxInstance;
    try {
      final model = box.values.firstWhere((category) => category.id == id);
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    final box = HiveService.categoriesBoxInstance;
    
    // Generate new ID
    final newId = box.values.isEmpty ? 1 : box.values.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    // Create category with new ID
    final categoryWithId = category.copyWith(id: newId);
    final model = CategoryHiveModel.fromEntity(categoryWithId);
    
    // Add to box
    await box.add(model);
    
    return model.toEntity();
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final box = HiveService.categoriesBoxInstance;
    
    final index = box.values.toList().indexWhere((c) => c.id == category.id);
    if (index == -1) throw StateError('Category not found');
    
    final model = CategoryHiveModel.fromEntity(category);
    await box.putAt(index, model);
    
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(int id) async {
    final box = HiveService.categoriesBoxInstance;
    
    final index = box.values.toList().indexWhere((c) => c.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  Future<List<Category>> getCategoriesWithBudget() async {
    final categories = await getAllCategories();
    return categories.where((category) => category.budget > 0).toList();
  }

  Future<Category> updateCategoryExpense(int categoryId, double expense) async {
    final box = HiveService.categoriesBoxInstance;
    
    final index = box.values.toList().indexWhere((c) => c.id == categoryId);
    if (index == -1) throw StateError('Category not found');
    
    final category = box.values.toList()[index];
    category.expense = expense;
    await box.putAt(index, category);
    
    return category.toEntity();
  }
}