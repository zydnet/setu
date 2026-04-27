import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/donatable_item.dart';
import '../../domain/entities/ngo.dart';
import '../bloc/ngo_bloc.dart';

class NgoProfileTab extends StatefulWidget {
  const NgoProfileTab({super.key});

  @override
  State<NgoProfileTab> createState() => _NgoProfileTabState();
}

class _NgoProfileTabState extends State<NgoProfileTab> {
  Ngo? _selectedNgo;
  final Map<ItemCategory, bool> _currentNeeds = {};

  final List<ItemCategory> _panelCategories = [
    ItemCategory.clothing,
    ItemCategory.books,
    ItemCategory.electronics,
    ItemCategory.toys,
    ItemCategory.food,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NgoBloc, NgoState>(
      builder: (context, state) {
        if (state is NgoLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is NgoLoaded) {
          final ngos = state.ngos;
          if (ngos.isEmpty) return const Center(child: Text('No NGOs available'));

          if (_selectedNgo != null && !ngos.any((n) => n.id == _selectedNgo!.id)) {
            _selectedNgo = null;
          }
          if (_selectedNgo == null && ngos.isNotEmpty) {
            // Auto-select first NGO to simulate being logged in as them
            _selectedNgo = ngos.first;
            _populateNeeds(_selectedNgo!);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: const [
                            Text('142', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            Text('Donations Received', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: const [
                            Text('8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            Text('Active Requests', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text('Simulate Logged-in NGO:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                DropdownButton<Ngo>(
                  value: _selectedNgo,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: ngos.map((ngo) => DropdownMenuItem<Ngo>(value: ngo, child: Text(ngo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))).toList(),
                  onChanged: (Ngo? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedNgo = newValue;
                        _populateNeeds(newValue);
                      });
                    }
                  },
                ),
                const Divider(height: 32),
                
                const Text('Our Current Requirements:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _panelCategories.length,
                    itemBuilder: (context, index) {
                      final category = _panelCategories[index];
                      final label = _getCategoryLabel(category);
                      return SwitchListTile(
                        title: Text(label),
                        value: _currentNeeds[category] ?? false,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) {
                          setState(() {
                            _currentNeeds[category] = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final updatedNeeds = Map<ItemCategory, bool>.from(_selectedNgo!.needs);
                      updatedNeeds.addAll(_currentNeeds);

                      context.read<NgoBloc>().add(
                        UpdateNgoNeedsEvent(_selectedNgo!.id, updatedNeeds)
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Requirements Updated Successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Update Requirements', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Failed to load NGOs'));
      },
    );
  }

  void _populateNeeds(Ngo ngo) {
    _currentNeeds.clear();
    for (var cat in _panelCategories) {
      _currentNeeds[cat] = ngo.needsCategory(cat);
    }
  }

  String _getCategoryLabel(ItemCategory category) {
    switch (category) {
      case ItemCategory.clothing: return 'Clothing';
      case ItemCategory.books: return 'Books';
      case ItemCategory.electronics: return 'Electronics';
      case ItemCategory.furniture: return 'Furniture';
      case ItemCategory.toys: return 'Toys';
      case ItemCategory.food: return 'Food';
      case ItemCategory.other: return 'Other';
    }
  }
}
