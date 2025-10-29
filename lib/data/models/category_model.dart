import 'package:flutter/material.dart';
import 'package:penpenny/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    required super.icon,
    required super.color,
    super.budget = 0.0,
    super.expense = 0.0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      budget: json['budget']?.toDouble() ?? 0.0,
      expense: json['expense']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'budget': budget,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      budget: category.budget,
      expense: category.expense,
    );
  }
}