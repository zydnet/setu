import 'package:equatable/equatable.dart';

enum ItemCategory {
  clothing,
  electronics,
  books,
  furniture,
  toys,
  food,
  other,
}

class DonatableItem extends Equatable {
  final String id;
  final String name;
  final ItemCategory category;
  final String condition;
  final String description;

  const DonatableItem({
    required this.id,
    required this.name,
    required this.category,
    required this.condition,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, category, condition, description];

  static ItemCategory categoryFromString(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('cloth') || lower.contains('jacket') || lower.contains('shirt')) {
      return ItemCategory.clothing;
    } else if (lower.contains('electr') || lower.contains('phone') || lower.contains('laptop')) {
      return ItemCategory.electronics;
    } else if (lower.contains('book') || lower.contains('textbook')) {
      return ItemCategory.books;
    } else if (lower.contains('furniture') || lower.contains('chair') || lower.contains('table')) {
      return ItemCategory.furniture;
    } else if (lower.contains('toy') || lower.contains('game')) {
      return ItemCategory.toys;
    } else if (lower.contains('food') || lower.contains('grocery') || lower.contains('meal')) {
      return ItemCategory.food;
    }
    return ItemCategory.other;
  }
}