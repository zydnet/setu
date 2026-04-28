import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ngo.dart';
import '../../domain/entities/donatable_item.dart';

class NgoDetailScreen extends StatelessWidget {
  final Ngo ngo;

  const NgoDetailScreen({super.key, required this.ngo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
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
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/ngo1.png', // Fallback, could use ngo.imageUrl
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ngo.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black87),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.near_me, color: AppColors.primary, size: 16),
                            SizedBox(width: 6),
                            Text('Nearby', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ngo.address,
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('About the Organization', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  const Text(
                    'We are dedicated to helping our local community by providing essential resources, shelter, and support to those in need. Your donations directly impact lives every single day.',
                    style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  const Text('Currently Accepting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ItemCategory.values
                      .where((cat) => ngo.needsCategory(cat))
                      .map((cat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          _getCategoryLabel(cat), 
                          style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold)
                        )
                      )).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildMockMap(context),
                  const SizedBox(height: 80), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
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
            onPressed: () => _showContactOptions(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Contact NGO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('Contact Organization', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
            const SizedBox(height: 24),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening email client...')));
              },
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.email, color: AppColors.primary),
              ),
              title: const Text('Send an Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('contact@${ngo.name.replaceAll(' ', '').toLowerCase()}.org'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.grey.shade50,
            ),
            const SizedBox(height: 12),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening dialer...')));
              },
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.phone, color: AppColors.secondary),
              ),
              title: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('+1 (555) 019-8372'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.grey.shade50,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMockMap(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Open in Maps', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Would you like to open your maps application to navigate to ${ngo.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Cancel', style: TextStyle(color: Colors.black54))
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _launchMaps(ngo.address);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Open Maps', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4), // Light map background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            // Mock street lines
            CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _MockMapPainter(),
            ),
            // Location Pin
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))
                      ]
                    ),
                    child: const Icon(Icons.domain, color: Colors.white, size: 24),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMaps(String address) async {
    final url = Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(address)}');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch map url');
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

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw some intersecting "streets"
    canvas.drawLine(const Offset(0, 50), Offset(size.width, 80), paint);
    canvas.drawLine(const Offset(0, 150), Offset(size.width, 120), paint);
    
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.6, size.height), paint);
    
    // Highlighted route
    paint.color = AppColors.secondary.withValues(alpha: 0.3);
    paint.strokeWidth = 8.0;
    canvas.drawLine(Offset(size.width * 0.3, 25), Offset(size.width * 0.5, 100), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
