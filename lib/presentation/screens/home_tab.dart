import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ngo.dart';
import '../../domain/entities/donatable_item.dart';
import '../bloc/ngo_bloc.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  ItemCategory? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Banner Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))
              ]
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomLeft,
              child: const Text(
                "Your donations\nmake a world\nof difference.",
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5),
              ),
            ),
          ),
        ),

        // Category Filter Toggle
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: ItemCategory.values.map((category) {
              final isSelected = _selectedCategoryFilter == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    _getCategoryLabel(category), 
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700)
                  ),
                  backgroundColor: Colors.white,
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  elevation: isSelected ? 6 : 1,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategoryFilter = selected ? category : null;
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ),
        
        Expanded(
          child: BlocBuilder<NgoBloc, NgoState>(
            builder: (context, state) {
              if (state is NgoLoading || state is NgoInitial) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (state is NgoLoaded) {
                final ngos = _selectedCategoryFilter == null
                    ? state.ngos
                    : state.ngos.where((n) => n.needsCategory(_selectedCategoryFilter!)).toList();

                if (ngos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No NGOs found matching your filter.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: ngos.length,
                  itemBuilder: (context, index) {
                    final ngo = ngos[index];
                    return _buildNgoCard(ngo, index);
                  },
                );
              }
              return const Center(child: Text('Error loading NGOs'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNgoCard(Ngo ngo, int index) {
    // Alternate images for the mock
    final imageAsset = index % 2 == 0 ? 'assets/images/ngo1.png' : 'assets/images/ngo2.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Image.asset(
            imageAsset,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ngo.name, 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ngo.address, 
                        style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('CURRENTLY NEEDS', 
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ItemCategory.values
                    .where((cat) => ngo.needsCategory(cat))
                    .map((cat) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1))
                      ),
                      child: Text(
                        _getCategoryLabel(cat), 
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)
                      )
                    )).toList(),
                ),
                if (ItemCategory.values.where((cat) => ngo.needsCategory(cat)).isEmpty)
                  const Text('No specific needs listed', style: TextStyle(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
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
