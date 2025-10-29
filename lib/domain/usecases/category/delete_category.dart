import 'package:penpenny/domain/repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(int categoryId) async {
    return await repository.deleteCategory(categoryId);
  }
}