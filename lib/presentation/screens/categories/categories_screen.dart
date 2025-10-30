import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/widgets/dialogs/category_form_dialog.dart';
import 'package:penpenny/presentation/widgets/optimized/optimized_list_view.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();

    globalEventEmitter.on(GlobalEventType.categoryUpdate.name, (data) {
      debugPrint("categories are changed");
      context.read<CategoriesBloc>().add(LoadCategories());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading categories',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoriesBloc>().add(LoadCategories());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is CategoriesLoaded && state.categories.isNotEmpty) {
            return OptimizedListView<Category>(
              items: state.categories,
              addRepaintBoundaries: true,
              cacheExtent: 600, // Pre-cache for smooth scrolling
              itemBuilder: (context, category, index) {
                double expenseProgress = (category.expense) / (category.budget);
                return ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (builder) => BlocProvider.value(
                        value: context.read<CategoriesBloc>(),
                        child: CategoryFormDialog(category: category),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: category.color.withOpacity(0.2),
                    child: Icon(category.icon, color: category.color),
                  ),
                  title: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                      const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  subtitle: expenseProgress.isFinite
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: expenseProgress,
                            semanticsLabel: expenseProgress.toString(),
                          ),
                        )
                      : Text(
                          "No budget",
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey.withAlpha(25),
                  height: 1,
                  margin: const EdgeInsets.only(left: 75, right: 20),
                );
              },
              emptyWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No categories yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add categories to organize your expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Handle empty state through OptimizedListView's emptyWidget
          if (state is CategoriesLoaded) {
            return OptimizedListView<Category>(
              items: state.categories,
              addRepaintBoundaries: true,
              cacheExtent: 600,
              itemBuilder: (context, category, index) {
                double expenseProgress = (category.expense) / (category.budget);
                return ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (builder) => BlocProvider.value(
                        value: context.read<CategoriesBloc>(),
                        child: CategoryFormDialog(category: category),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: category.color.withAlpha(51),
                    child: Icon(category.icon, color: category.color),
                  ),
                  title: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                      const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  subtitle: expenseProgress.isFinite
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: expenseProgress,
                            semanticsLabel: expenseProgress.toString(),
                          ),
                        )
                      : Text(
                          "No budget",
                          style: Theme.of(context).textTheme.bodySmall?.apply(
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey.withAlpha(25),
                  height: 1,
                  margin: const EdgeInsets.only(left: 75, right: 20),
                );
              },
              emptyWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No categories yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add categories to organize your expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Default case - should not happen
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (builder) => BlocProvider.value(
              value: context.read<CategoriesBloc>(),
              child: const CategoryFormDialog(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}