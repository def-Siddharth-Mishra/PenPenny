import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  Future<Category> call(Category category) async {
    return await repository.createCategory(category);
  }
}