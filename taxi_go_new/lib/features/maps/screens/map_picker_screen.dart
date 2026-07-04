import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/services/location_service.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';

/// Result returned by [MapPickerScreen.pick] - the address is best-effort
/// reverse-geocoded from the picked coordinates and may be empty if
/// `geocoding` fails to resolve it (e.g. no network); the caller should let
/// the user edit/fill the address manually in that case.
class MapPickResult {
  final double latitude;
  final double longitude;
  final String address;

  const MapPickResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Lets the user pick a single point on a real Google Map (tap or drag the
/// marker), then reverse-geocodes it into a human-readable address before
/// returning. Used for both pickup and dropoff selection on
/// `CreateOrderScreen`.
class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String title;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.title = 'Select Location',
  });

  /// Convenience helper - pushes the screen and returns the picked result,
  /// or null if the user backed out without confirming.
  static Future<MapPickResult?> pick(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
    String title = 'Select Location',
  }) {
    return Navigator.push<MapPickResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          title: title,
        ),
      ),
    );
  }

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const LatLng _fallbackCenter = LatLng(31.9038, 35.2034); // Ramallah

  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  late LatLng _picked;
  bool _resolvingAddress = false;
  bool _locatingDevice = false;

  @override
  void initState() {
    super.initState();
    _picked = (widget.initialLatitude != null && widget.initialLongitude != null)
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _fallbackCenter;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locatingDevice = true);

    try {
      final position = await _locationService.getCurrentLocation();
      final target = LatLng(position.latitude, position.longitude);

      setState(() => _picked = target);
      _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _locatingDevice = false);
    }
  }

  Future<String> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return '';

      final p = placemarks.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].where((part) => part != null && part.trim().isNotEmpty).toList();

      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  Future<void> _confirm() async {
    setState(() => _resolvingAddress = true);

    final address = await _reverseGeocode(_picked);

    if (!mounted) return;

    Navigator.pop(
      context,
      MapPickResult(
        latitude: _picked.latitude,
        longitude: _picked.longitude,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The map stays full-bleed (wrapping the whole Stack in SafeArea would
    // inset the map itself), but the floating buttons are `Positioned` by a
    // raw `bottom:` distance from the screen edge - on a device with a
    // gesture/button system nav bar, that inset wasn't accounted for and the
    // confirm button could end up partially under it. Adding the system
    // bottom inset to each button's offset keeps the map edge-to-edge while
    // keeping the buttons clear of the nav bar.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _picked, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (position) => setState(() => _picked = position),
            markers: {
              Marker(
                markerId: const MarkerId('picked'),
                position: _picked,
                draggable: true,
                onDragEnd: (position) => setState(() => _picked = position),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            right: 16,
            bottom: 96 + bottomInset,
            child: FloatingActionButton(
              heroTag: 'use-current-location',
              onPressed: _locatingDevice ? null : _useCurrentLocation,
              child: _locatingDevice
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md + bottomInset,
            child: AppPrimaryButton(
              label: AppLocalizations.of(context)!.mapConfirmLocation,
              icon: Icons.check_circle_outline,
              isLoading: _resolvingAddress,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
