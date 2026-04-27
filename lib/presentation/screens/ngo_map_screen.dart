import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/ngo.dart';

class NgoMapScreen extends StatefulWidget {
  final List<Ngo> ngos;
  final Ngo? selectedNgo;

  const NgoMapScreen({super.key, required this.ngos, this.selectedNgo});

  @override
  State<NgoMapScreen> createState() => _NgoMapScreenState();
}

class _NgoMapScreenState extends State<NgoMapScreen> {
  // ignore: unused_field - kept for future map operations
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Locations'),
        backgroundColor: AppColors.primary,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.selectedNgo?.latitude ?? 37.7749,
            widget.selectedNgo?.longitude ?? -122.4194,
          ),
          zoom: 12,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _buildMarkers(),
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return widget.ngos.map((ngo) {
      return Marker(
        markerId: MarkerId(ngo.id),
        position: LatLng(ngo.latitude, ngo.longitude),
        infoWindow: InfoWindow(
          title: ngo.name,
          snippet: ngo.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet();
  }
}