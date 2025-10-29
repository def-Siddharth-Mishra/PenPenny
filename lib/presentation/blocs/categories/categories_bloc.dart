import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/domain/repositories/category_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository repository;

  CategoriesBloc(this.repository) : super(CategoriesInitial()) {
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
      final categories = await repository.getAllCategories();
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
      await repository.createCategory(event.category);
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
      await repository.updateCategory(event.category);
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
      await repository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}