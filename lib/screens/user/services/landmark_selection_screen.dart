// lib/screens/user/services/landmark_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../services/maps_service.dart';
import '../../../utils/app_colors.dart';

class LandmarkSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;
  
  const LandmarkSelectionScreen({super.key, this.initialLocation});

  @override
  State<LandmarkSelectionScreen> createState() => _LandmarkSelectionScreenState();
}

class _LandmarkSelectionScreenState extends State<LandmarkSelectionScreen> {
  LatLng _selectedPosition = const LatLng(17.3850, 78.4867); // Hyderabad default
  String? _address;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = widget.initialLocation!;
    }
    _updateAddress(_selectedPosition);
  }

  Future<void> _updateAddress(LatLng position) async {
    setState(() => _isLocating = true);
    final mapsService = Provider.of<MapsService>(context, listen: false);
    final address = await mapsService.getAddressFromLatLng(position);
    if (mounted) {
      setState(() {
        _address = address ?? "Unknown Location";
        _isLocating = false;
      });
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateAddress(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Service Location',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (_) {},
            onTap: _onMapTapped,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          
          // Selection Info Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _isLocating
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _address ?? "Fetching address...",
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLocating
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'position': _selectedPosition,
                              'address': _address,
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: Text(
                      'Confirm Location',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instruction Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tap on the map to pick your location',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
