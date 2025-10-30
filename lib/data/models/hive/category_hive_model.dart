import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:penpenny/domain/entities/category.dart';

part 'category_hive_model.g.dart';

// Helper to create IconData that can be tree-shaken
class IconDataHelper {
  static const IconData _defaultIcon = Icons.category;
  
  static IconData fromCodePoint(int codePoint) {
    // Use a switch or map to return const IconData instances
    // This allows Flutter to tree-shake properly
    switch (codePoint) {
      case 0xe57e: return Icons.category;
      case 0xe56c: return Icons.shopping_cart;
      case 0xe57f: return Icons.restaurant;
      case 0xe530: return Icons.local_gas_station;
      case 0xe559: return Icons.movie;
      default: return const IconData(0xe57e, fontFamily: 'MaterialIcons'); // Default category icon
    }
  }
}

@HiveType(typeId: 1)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  double budget;

  @HiveField(5)
  double expense;

  CategoryHiveModel({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.budget = 0.0,
    this.expense = 0.0,
  });

  factory CategoryHiveModel.fromEntity(Category category) {
    return CategoryHiveModel(
      id: category.id,
      name: category.name,
      iconCodePoint: category.icon.codePoint,
      colorValue: category.color.value,
      budget: category.budget,
      expense: category.expense,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: IconDataHelper.fromCodePoint(iconCodePoint),
      color: Color(colorValue),
      budget: budget,
      expense: expense,
    );
  }
}