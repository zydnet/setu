class DonationRequest {
  final String id;
  final String donorName;
  final String itemName;
  final String category;
  final String distance;
  final String time;
  final String deliveryPreference;

  DonationRequest({
    required this.id,
    required this.donorName,
    required this.itemName,
    required this.category,
    required this.distance,
    required this.time,
    required this.deliveryPreference,
  });
}
