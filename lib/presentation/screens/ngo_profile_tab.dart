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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, bottom: 40, left: 24, right: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('NGO DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
                      ),
                      const SizedBox(height: 24),
                      Text(_selectedNgo!.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(_selectedNgo!.address, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Analytics Cards
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildAnalyticCard('Items Received', '142', Icons.inventory_2, AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnalyticCard('Active Requests', '8', Icons.campaign, Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Requirements
                      const Text('Active Requirements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                      const SizedBox(height: 8),
                      const Text('Toggle categories to instantly notify local donors of your needs.', style: TextStyle(color: Colors.black54, height: 1.4)),
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: _panelCategories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            return Column(
                              children: [
                                SwitchListTile(
                                  title: Text(_getCategoryLabel(category), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(_currentNeeds[category] == true ? 'Actively seeking' : 'Not required right now', style: TextStyle(fontSize: 12, color: _currentNeeds[category] == true ? AppColors.primary : Colors.grey)),
                                  value: _currentNeeds[category] ?? false,
                                  activeColor: AppColors.primary,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _currentNeeds[category] = value;
                                    });
                                  },
                                ),
                                if (index < _panelCategories.length - 1)
                                  const Divider(height: 1, indent: 20, endIndent: 20),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final updatedNeeds = Map<ItemCategory, bool>.from(_selectedNgo!.needs);
                            updatedNeeds.addAll(_currentNeeds);
                            context.read<NgoBloc>().add(UpdateNgoNeedsEvent(_selectedNgo!.id, updatedNeeds));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requirements Broadcasted Successfully!')));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text('Update & Broadcast Needs', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Demo Account Switcher
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.developer_board, color: Colors.grey, size: 16),
                                SizedBox(width: 8),
                                Text('DEMO CONTROLS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Simulate logged-in organization:', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Ngo>(
                                  value: _selectedNgo,
                                  isExpanded: true,
                                  icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                                  items: ngos.map((ngo) => DropdownMenuItem<Ngo>(value: ngo, child: Text(ngo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))).toList(),
                                  onChanged: (Ngo? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedNgo = newValue;
                                        _populateNeeds(newValue);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
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

  Widget _buildAnalyticCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
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
