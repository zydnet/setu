import 'package:equatable/equatable.dart';
import 'donatable_item.dart';

class Ngo extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final Map<ItemCategory, bool> needs;

  const Ngo({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.needs,
  });

  bool needsCategory(ItemCategory category) => needs[category] ?? false;

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, needs];

  factory Ngo.fromJson(String id, Map<dynamic, dynamic> json) {
    final needsMap = json['needs'] as Map<dynamic, dynamic>? ?? {};
    final convertedNeeds = <ItemCategory, bool>{};
    
    needsMap.forEach((key, value) {
      final category = _parseCategory(key.toString());
      if (category != null) {
        convertedNeeds[category] = value as bool? ?? false;
      }
    });

    return Ngo(
      id: id,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      needs: convertedNeeds,
    );
  }

  static ItemCategory? _parseCategory(String key) {
    switch (key.toLowerCase()) {
      case 'clothing':
        return ItemCategory.clothing;
      case 'electronics':
        return ItemCategory.electronics;
      case 'books':
        return ItemCategory.books;
      case 'furniture':
        return ItemCategory.furniture;
      case 'toys':
        return ItemCategory.toys;
      case 'food':
        return ItemCategory.food;
      case 'other':
        return ItemCategory.other;
      default:
        return null;
    }
  }
}