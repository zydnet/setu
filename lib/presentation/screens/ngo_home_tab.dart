import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/donation_bloc.dart';
import 'incoming_donation_detail_screen.dart';

class NgoHomeTab extends StatelessWidget {
  const NgoHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonationBloc, DonationState>(
      builder: (context, state) {
        final donations = state.donations;

        if (donations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No Incoming Donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                const Text('When donors post items, they will appear here.', style: TextStyle(color: Colors.black45)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final donation = donations[index];
            final isPickup = donation.deliveryPreference == 'Pickup Requested';
            final isBroadcast = donation.deliveryPreference == 'Broadcast Request';
            
            Color labelBgColor = AppColors.primary.withValues(alpha: 0.1);
            Color labelTextColor = AppColors.primary;
            IconData labelIcon = Icons.directions_car;

            if (isPickup) {
              labelBgColor = Colors.orange.withValues(alpha: 0.1);
              labelTextColor = Colors.orange.shade800;
              labelIcon = Icons.local_shipping;
            } else if (isBroadcast) {
              labelBgColor = Colors.red.withValues(alpha: 0.1);
              labelTextColor = Colors.red.shade700;
              labelIcon = Icons.sensors;
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncomingDonationDetailScreen(donation: donation)),
                );
              },
              child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
                ],
                border: isBroadcast ? Border.all(color: Colors.red.shade200, width: 2) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBroadcast)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flash_on, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('LIVE BROADCAST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation.category.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black45, letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    donation.itemName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87),
                                  ),
                                ],
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
                                  const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(donation.distance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18, 
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Donated by', style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5))),
                                Text(donation.donorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            const Spacer(),
                            Text(donation.time, style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: labelBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(labelIcon, size: 18, color: labelTextColor),
                              const SizedBox(width: 12),
                              Expanded(child: Text(donation.deliveryPreference, style: TextStyle(fontWeight: FontWeight.bold, color: labelTextColor))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<DonationBloc>().add(RemoveDonationEvent(donation.id));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBroadcast ? 'Item Claimed! Donor Notified.' : 'Connection request sent to donor!')));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBroadcast ? Colors.red : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(isBroadcast ? 'Claim Broadcasted Item' : 'Accept & Connect', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        );
      },
    );
  }
}
