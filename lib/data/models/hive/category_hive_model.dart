import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:penpenny/domain/entities/category.dart';

part 'category_hive_model.g.dart';

// Helper method to create IconData from codePoint
IconData _createIconData(int codePoint) {
  return IconData(codePoint, fontFamily: 'MaterialIcons');
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
      icon: _createIconData(iconCodePoint),
      color: Color(colorValue),
      budget: budget,
      expense: expense,
    );
  }
}