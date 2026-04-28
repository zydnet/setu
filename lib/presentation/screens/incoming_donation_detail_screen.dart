import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/donation_request.dart';
import '../bloc/donation_bloc.dart';

class IncomingDonationDetailScreen extends StatelessWidget {
  final DonationRequest donation;

  const IncomingDonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final isBroadcast = donation.deliveryPreference == 'Broadcast Request';
    
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'donation_image_${donation.id}',
              child: Image.asset(
                donation.imageUrl,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          donation.category.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
                        ),
                      ),
                      Text(donation.time, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    donation.itemName,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24, 
                        backgroundColor: Colors.grey.shade100,
                        child: const Icon(Icons.person, color: Colors.grey, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Donated by', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(donation.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.near_me, size: 16, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(donation.distance, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(
                    donation.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Location: ${donation.distance} (Approx)', 
                        style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isBroadcast ? Colors.red.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isBroadcast ? Colors.red.shade200 : Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivery Preference', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(isBroadcast ? Icons.sensors : Icons.local_shipping, color: isBroadcast ? Colors.red.shade700 : Colors.black87),
                            const SizedBox(width: 12),
                            Text(donation.deliveryPreference, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isBroadcast ? Colors.red.shade700 : Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<DonationBloc>().add(RemoveDonationEvent(donation.id));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBroadcast ? 'Item Claimed! Donor Notified.' : 'Connection request sent to donor!')));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isBroadcast ? Colors.red : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isBroadcast ? 'Claim Broadcasted Item' : 'Accept & Connect', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
