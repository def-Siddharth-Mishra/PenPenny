import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final double budget;
  final double expense;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budget = 0.0,
    this.expense = 0.0,
  });

  Category copyWith({
    int? id,
    String? name,
    IconData? icon,
    Color? color,
    double? budget,
    double? expense,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      expense: expense ?? this.expense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}