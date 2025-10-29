import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/usecases/category/create_category.dart' as category_create_usecase;
import 'package:penpenny/domain/usecases/category/delete_category.dart' as category_delete_usecase;
import 'package:penpenny/domain/usecases/category/get_all_categories.dart';
import 'package:penpenny/domain/usecases/category/update_category.dart' as category_update_usecase;

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetAllCategories getAllCategories;
  final category_create_usecase.CreateCategory createCategory;
  final category_update_usecase.UpdateCategory updateCategory;
  final category_delete_usecase.DeleteCategory deleteCategory;

  CategoriesBloc({
    required this.getAllCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      emit(CategoriesLoading());
      final categories = await getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await createCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}