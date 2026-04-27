import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/donatable_item.dart';
import '../../domain/entities/ngo.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/ngo_bloc.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    final state = context.read<ScanBloc>().state;
    if (state is ScanSuccess) {
      context.read<NgoBloc>().add(MatchNgosEvent(state.item.category));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Found'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<ScanBloc, ScanState>(
        builder: (context, scanState) {
          if (scanState is ScanLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  if (scanState.preliminaryLabel != null) ...[
                    Text('Possible Category:', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${scanState.preliminaryLabel}', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    const Text('Getting donation details...', style: TextStyle(color: AppColors.textSecondary)),
                  ] else ...[
                    const Text('Analyzing item...', style: TextStyle(color: AppColors.textSecondary)),
                  ]
                ],
              ),
            );
          }

          if (scanState is ScanError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(scanState.message, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('TRY AGAIN'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (scanState is ScanSuccess) {
            return _buildResultContent(scanState.item);
          }

          return const Center(child: Text('No item detected'));
        },
      ),
    );
  }

  Widget _buildResultContent(DonatableItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildCategoryChip(item.category),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow('Condition', item.condition),
                  const SizedBox(height: 12),
                  Text(item.description, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nearby NGOs that need this', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          BlocBuilder<NgoBloc, NgoState>(
            builder: (context, ngoState) {
              if (ngoState is NgoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (ngoState is NgoLoaded) {
                if (ngoState.matchedNgos.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, size: 48, color: AppColors.secondary),
                          const SizedBox(height: 12),
                          const Text('No NGOs currently need this item', textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          const Text('Try again later or with a different item', 
                            style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: ngoState.matchedNgos.map((ngo) => _buildNgoCard(ngo)).toList(),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ItemCategory category) {
    final labels = {
      ItemCategory.clothing: 'Clothing',
      ItemCategory.electronics: 'Electronics',
      ItemCategory.books: 'Books',
      ItemCategory.furniture: 'Furniture',
      ItemCategory.other: 'Other',
    };
    
    return Chip(
      label: Text(labels[category] ?? 'Other'),
      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
    );
  }

Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildNgoCard(Ngo ngo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ngo.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('NEEDS THIS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(ngo.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToNgo(ngo),
                    icon: const Icon(Icons.directions),
                    label: const Text('GET DIRECTIONS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNgo(Ngo ngo) {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${ngo.latitude},${ngo.longitude}');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}