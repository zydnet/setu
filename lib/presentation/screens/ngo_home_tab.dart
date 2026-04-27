import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/donation_bloc.dart';

class NgoHomeTab extends StatelessWidget {
  const NgoHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Incoming Donations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: BlocBuilder<DonationBloc, DonationState>(
            builder: (context, state) {
              final donations = state.donations;

              if (donations.isEmpty) {
                return const Center(child: Text('No incoming donations right now.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  final isPickup = donation.deliveryPreference == 'Pickup Requested';
                  final isBroadcast = donation.deliveryPreference == 'Broadcast Request';
                  
                  Color labelBgColor = Colors.green.shade50;
                  Color labelTextColor = Colors.green.shade800;
                  IconData labelIcon = Icons.directions_car;

                  if (isPickup) {
                    labelBgColor = Colors.orange.shade50;
                    labelTextColor = Colors.orange.shade800;
                    labelIcon = Icons.local_shipping;
                  } else if (isBroadcast) {
                    labelBgColor = Colors.blue.shade50;
                    labelTextColor = Colors.blue.shade800;
                    labelIcon = Icons.campaign;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 16, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Text(donation.donorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Text(donation.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Offering: ${donation.itemName}', style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.category, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(donation.category, style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(width: 16),
                              const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(donation.distance, style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: labelBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(labelIcon, size: 16, color: labelTextColor),
                                const SizedBox(width: 8),
                                Text(donation.deliveryPreference, style: TextStyle(fontWeight: FontWeight.bold, color: labelTextColor)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBroadcast ? 'Item Claimed! Donor Notified.' : 'Connection request sent to donor!')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(isBroadcast ? 'Claim Item' : 'Accept & Connect'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
