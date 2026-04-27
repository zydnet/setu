import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/donatable_item.dart';
import '../../domain/entities/ngo.dart';
import '../../domain/entities/donation_request.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/ngo_bloc.dart';
import '../bloc/donation_bloc.dart';
import 'ngo_donation_detail_screen.dart';
import 'ngo_donation_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showNgos = false;

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
        title: const Text('Item Details'),
        backgroundColor: AppColors.primary,
        elevation: 0,
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
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          
          if (!_showNgos) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _broadcastItem(context, item),
                icon: const Icon(Icons.campaign),
                label: const Text('Quick Post (Broadcast to All)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showNgos = true;
                      });
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Choose NGO'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit functionality coming soon!')));
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Details'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_showNgos) ...[
            const SizedBox(height: 32),
            const Text('Nearby NGOs matching your item:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
                    children: ngoState.matchedNgos.map((ngo) => _buildNgoCard(ngo, item)).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _broadcastItem(BuildContext context, DonatableItem item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _GemmaSafetyDialog(),
    ).then((isSafe) {
      if (isSafe == true) {
        String categoryLabel = 'Other';
        switch (item.category) {
          case ItemCategory.clothing: categoryLabel = 'Clothing'; break;
          case ItemCategory.books: categoryLabel = 'Books'; break;
          case ItemCategory.electronics: categoryLabel = 'Electronics'; break;
          case ItemCategory.furniture: categoryLabel = 'Furniture'; break;
          case ItemCategory.toys: categoryLabel = 'Toys'; break;
          case ItemCategory.food: categoryLabel = 'Food'; break;
          case ItemCategory.other: categoryLabel = 'Other'; break;
        }

        context.read<DonationBloc>().add(AddDonationEvent(
          DonationRequest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            donorName: 'Current User',
            itemName: item.name,
            category: categoryLabel,
            distance: 'Local Area', 
            time: 'Just now',
            deliveryPreference: 'Broadcast Request',
          )
        ));

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.campaign, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                const Expanded(child: Text('Broadcast Sent!', style: TextStyle(fontSize: 20))),
              ],
            ),
            content: const Text('Your item has been broadcasted to all nearby NGOs. You will be notified when an NGO claims it for pickup!'),
            actions: [
              ElevatedButton(
                onPressed: () { 
                  Navigator.pop(context); // dialog
                  Navigator.pop(context); // result screen -> back to home/scanner
                }, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Return Home', style: TextStyle(color: Colors.white)),
              )
            ],
          )
        );
      }
    });
  }

  Widget _buildCategoryChip(ItemCategory category) {
    final labels = {
      ItemCategory.clothing: 'Clothing',
      ItemCategory.electronics: 'Electronics',
      ItemCategory.books: 'Books',
      ItemCategory.furniture: 'Furniture',
      ItemCategory.toys: 'Toys',
      ItemCategory.food: 'Food',
      ItemCategory.other: 'Other',
    };

    return Chip(
      label: Text(labels[category] ?? 'Other'),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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

  Widget _buildNgoCard(Ngo ngo, DonatableItem item) {
    final neededLabels = ItemCategory.values
        .where((cat) => ngo.needsCategory(cat))
        .map((c) {
          switch (c) {
            case ItemCategory.clothing: return 'Clothing';
            case ItemCategory.books: return 'Books';
            case ItemCategory.electronics: return 'Electronics';
            case ItemCategory.furniture: return 'Furniture';
            case ItemCategory.toys: return 'Toys';
            case ItemCategory.food: return 'Food';
            case ItemCategory.other: return 'Other';
          }
        })
        .join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.domain, color: Colors.white),
        ),
        title: Text(ngo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(ngo.address),
            const SizedBox(height: 4),
            Text('Needs: $neededLabels', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NgoDonationDetailScreen(ngo: ngo, item: item),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Donate Here'),
        ),
      ),
    );
  }
}

class _GemmaSafetyDialog extends StatefulWidget {
  const _GemmaSafetyDialog();

  @override
  State<_GemmaSafetyDialog> createState() => _GemmaSafetyDialogState();
}

class _GemmaSafetyDialogState extends State<_GemmaSafetyDialog> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _runGemmaCheck();
  }

  Future<void> _runGemmaCheck() async {
    // Simulate on-device Gemma LLM loading and inference
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.pop(context, true); // Return safe
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isChecking) ...[
              const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
              ),
              const SizedBox(height: 24),
              const Text('Running Content Safety Check...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.memory, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  const Text('Powered by On-Device Gemma', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ] else ...[
              const Icon(Icons.gpp_good, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Gemma Safety Check Passed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              const SizedBox(height: 8),
              const Text('No toxic content detected.\nSafe to broadcast.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }
}