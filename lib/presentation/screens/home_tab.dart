import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ngo.dart';
import '../../domain/entities/donatable_item.dart';
import '../bloc/ngo_bloc.dart';
import 'ngo_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  ItemCategory? _selectedCategoryFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-bleed Hero Banner
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(28),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('YOUR IMPACT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Make a world\nof difference.",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('What can you give today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
          ),

          // Category Filter Toggle
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: ItemCategory.values.map((category) {
                final isSelected = _selectedCategoryFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryFilter = isSelected ? null : category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                      ),
                      child: Text(
                        _getCategoryLabel(category),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Nearby Organizations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
          ),

          BlocBuilder<NgoBloc, NgoState>(
            builder: (context, state) {
              if (state is NgoLoading || state is NgoInitial) {
                return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (state is NgoLoaded) {
                final ngos = _selectedCategoryFilter == null
                    ? state.ngos
                    : state.ngos.where((n) => n.needsCategory(_selectedCategoryFilter!)).toList();

                if (ngos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No NGOs found matching your filter.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildNgoCard(Ngo ngo, int index) {
    // Alternate images for the mock
    final imageAsset = index % 2 == 0 ? 'assets/images/ngo1.png' : 'assets/images/ngo2.png';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NgoDetailScreen(ngo: ngo)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imageAsset,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          // Title and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ngo.name, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      index % 2 == 0 ? '750m away' : '1.7km away', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ngo.address, 
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 15),
          ),
          const SizedBox(height: 16),
          // Needs chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ItemCategory.values
              .where((cat) => ngo.needsCategory(cat))
              .map((cat) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryLabel(cat), 
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)
                )
              )).toList(),
          ),
        ],
      ),
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
