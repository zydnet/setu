import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/donatable_item.dart';
import '../../domain/entities/ngo.dart';
import '../bloc/ngo_bloc.dart';

class NgoPanelScreen extends StatefulWidget {
  const NgoPanelScreen({super.key});

  @override
  State<NgoPanelScreen> createState() => _NgoPanelScreenState();
}

class _NgoPanelScreenState extends State<NgoPanelScreen> {
  Ngo? _selectedNgo;
  final Map<ItemCategory, bool> _currentNeeds = {};

  // Only show the specific categories required for the panel
  final List<ItemCategory> _panelCategories = [
    ItemCategory.clothing,
    ItemCategory.books,
    ItemCategory.electronics,
    ItemCategory.toys,
    ItemCategory.food,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Panel'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<NgoBloc, NgoState>(
        builder: (context, state) {
          if (state is NgoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is NgoLoaded) {
            final ngos = state.ngos;
            if (ngos.isEmpty) {
              return const Center(child: Text('No NGOs available'));
            }

            // Handle the case where the selected NGO no longer exists
            if (_selectedNgo != null && !ngos.any((n) => n.id == _selectedNgo!.id)) {
              _selectedNgo = null;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select NGO to edit needs:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Ngo>(
                    value: _selectedNgo,
                    hint: const Text('Select an NGO'),
                    isExpanded: true,
                    items: ngos.map((ngo) {
                      return DropdownMenuItem<Ngo>(
                        value: ngo,
                        child: Text(ngo.name),
                      );
                    }).toList(),
                    onChanged: (Ngo? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedNgo = newValue;
                          _currentNeeds.clear();
                          // Initialize toggles from the selected NGO's needs
                          for (var cat in _panelCategories) {
                            _currentNeeds[cat] = newValue.needsCategory(cat);
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedNgo != null) ...[
                    const Text(
                      'Category Needs:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                          // Merge existing needs with updated panel needs
                          final updatedNeeds = Map<ItemCategory, bool>.from(_selectedNgo!.needs);
                          updatedNeeds.addAll(_currentNeeds);

                          context.read<NgoBloc>().add(
                            UpdateNgoNeedsEvent(_selectedNgo!.id, updatedNeeds)
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('NGO Needs Updated!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return const Center(child: Text('Failed to load NGOs'));
        },
      ),
    );
  }

  String _getCategoryLabel(ItemCategory category) {
    switch (category) {
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.books:
        return 'Books';
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.furniture:
        return 'Furniture';
      case ItemCategory.toys:
        return 'Toys';
      case ItemCategory.food:
        return 'Food';
      case ItemCategory.other:
        return 'Other';
    }
  }
}
