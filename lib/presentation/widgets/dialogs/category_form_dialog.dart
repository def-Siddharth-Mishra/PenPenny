import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/data/app_icons.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/core/logging/app_logger.dart';
import 'package:penpenny/core/validation/validators.dart';
import 'package:penpenny/domain/entities/category.dart';
import 'package:penpenny/presentation/blocs/categories/categories_bloc.dart';
import 'package:penpenny/presentation/widgets/common/app_button.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';

typedef Callback = void Function();

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final Callback? onSave;

  const CategoryFormDialog({super.key, this.category, this.onSave});

  @override
  State<StatefulWidget> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  Category _category = const Category(
    name: "",
    icon: Icons.wallet_outlined,
    color: Colors.pink,
  );
  
  CategoriesBloc? _categoriesBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get the bloc reference
    _categoriesBloc = context.read<CategoriesBloc>();
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _budgetController.text = widget.category!.budget == 0 ? "" : widget.category!.budget.toString();
      _category = widget.category!;
    } else {
      _category = const Category(
        name: "",
        icon: Icons.wallet_outlined,
        color: Colors.pink,
      );
    }
    
    // Add listeners to sync controllers with category state
    _nameController.addListener(() {
      if (_nameController.text != _category.name) {
        setState(() {
          _category = _category.copyWith(name: _nameController.text);
        });
      }
    });
    
    _budgetController.addListener(() {
      final budgetText = _budgetController.text;
      final budgetValue = double.tryParse(budgetText) ?? 0.0;
      if (budgetValue != _category.budget) {
        setState(() {
          _category = _category.copyWith(budget: budgetValue);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void onSave() async {
    try {
      // Ensure the category has the latest values from controllers
      final finalCategory = _category.copyWith(
        name: _nameController.text.trim(),
        budget: double.tryParse(_budgetController.text) ?? 0.0,
      );
      
      // Validate the category
      final validationResult = CategoryValidator.validate(finalCategory);
      if (validationResult.hasErrors) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationResult.errors.values.first),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      AppLogger.info('Saving category: ${finalCategory.name}, budget: ${finalCategory.budget}', tag: 'CategoryFormDialog');
      
      if (_categoriesBloc != null) {
        if (widget.category != null) {
          AppLogger.info('Updating existing category with ID: ${widget.category!.id}', tag: 'CategoryFormDialog');
          _categoriesBloc!.add(UpdateCategory(finalCategory));
        } else {
          AppLogger.info('Creating new category', tag: 'CategoryFormDialog');
          _categoriesBloc!.add(CreateCategory(finalCategory));
        }
        
        if (widget.onSave != null) {
          widget.onSave!();
        }
        globalEventEmitter.emit(GlobalEventType.categoryUpdate.name);
        
        // Close dialog after dispatching the event
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        AppLogger.error('CategoriesBloc is null - cannot save category', tag: 'CategoryFormDialog');
        throw StateError('CategoriesBloc is not available');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving category', tag: 'CategoryFormDialog', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save category. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void onDelete() async {
    if (widget.category?.id == null) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${widget.category!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        debugPrint('Deleting category with ID: ${widget.category!.id}');
        _categoriesBloc?.add(DeleteCategory(widget.category!.id!));
        
        globalEventEmitter.emit(GlobalEventType.categoryUpdate.name);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error deleting category: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      bloc: _categoriesBloc,
      listener: (context, state) {
        if (state is CategoriesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.all(10),
      title: Text(
        widget.category != null ? "Edit Category" : "New Category",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: _category.color,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_category.icon, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter Category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),

                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              child: TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Budget',
                  hintText: 'Enter budget',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: CurrencyText(null),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),

              ),
            ),
            const SizedBox(height: 20),
            // Color picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppIcons.colors.length,
                itemBuilder: (BuildContext context, index) => Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _category = _category.copyWith(color: AppIcons.colors[index]);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppIcons.colors[index],
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          width: 2,
                          color: _category.color.value == AppIcons.colors[index].value
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Icon picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppIcons.icons.length,
                itemBuilder: (BuildContext context, index) => Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _category = _category.copyWith(icon: AppIcons.icons[index]);
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: _category.icon == AppIcons.icons[index]
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        AppIcons.icons[index],
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.category != null) ...[
          AppButton(
            height: 45,
            isFullWidth: true,
            onPressed: onDelete,
            color: Colors.red,
            label: "Delete",
          ),
          const SizedBox(height: 10),
        ],
        ValueListenableBuilder(
          valueListenable: _nameController,
          builder: (context, value, child) {
            final isValid = _nameController.text.trim().isNotEmpty;
            return AppButton(
              height: 45,
              isFullWidth: true,
              onPressed: isValid ? () {
                onSave();
              } : null,
              color: Theme.of(context).colorScheme.primary,
              label: "Save",
            );
          },
        )
      ],
    ),
    );
  }
}