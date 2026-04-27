import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ngo.dart';
import '../../domain/entities/donatable_item.dart';
import '../../domain/entities/donation_request.dart';
import '../bloc/donation_bloc.dart';

class NgoDonationDetailScreen extends StatelessWidget {
  final Ngo ngo;
  final DonatableItem item;
  
  const NgoDonationDetailScreen({super.key, required this.ngo, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Delivery'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.volunteer_activism, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Text(ngo.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(ngo.address, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary))),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description: We are a local community organization dedicated to distributing essential resources to those in need. Your donations directly impact families in your area.', 
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 32),
            const Text('Select Handover Method:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Pickup Option
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  _dispatchDonationEvent(context, 'Pickup Requested');
                  _showSuccessDialog(context, 'Pickup Scheduled!', 'A volunteer from ${ngo.name} will contact you shortly to arrange a pickup time at your home address.');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_shipping, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NGO Home Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 4),
                            Text('A volunteer will collect the item directly from your home.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Dropoff Option
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  _showDeliveryConfirmation(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car, color: AppColors.secondary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('I will Deliver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 4),
                            Text('Get directions and drop it off yourself at the NGO location.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void _dispatchDonationEvent(BuildContext context, String preference) {
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
        distance: '0.1 miles away', // Mock dynamic distance
        time: 'Just now',
        deliveryPreference: preference,
      )
    ));
  }

  void _showDeliveryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delivery'),
        content: Text('Are you ready to deliver this item to ${ngo.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              
              _dispatchDonationEvent(context, 'Donor Delivering');

              // Show sent notice
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Donation notice sent to ${ngo.name}!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Small delay to read the snackbar before flipping to external map
              await Future.delayed(const Duration(seconds: 1));
              _navigateToNgo(ngo);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm & Get Directions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToNgo(Ngo ngo) {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${ngo.latitude},${ngo.longitude}');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showSuccessDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            onPressed: () { 
              // Pop dialog
              Navigator.pop(context); 
              // Pop detail screen
              Navigator.pop(context); 
              // Pop result screen back to scanner
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Return Home', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }
}
