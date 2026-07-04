import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:taxi_go_new/core/services/location_service.dart';
import 'package:taxi_go_new/core/theme/app_spacing.dart';
import 'package:taxi_go_new/core/widgets/widgets.dart';
import 'package:taxi_go_new/features/maps/screens/map_picker_screen.dart';
import 'package:taxi_go_new/features/passenger/presentation/cubit/order_cubit.dart';
import 'package:taxi_go_new/features/passenger/presentation/screens/order_detail_screen.dart';
import 'package:taxi_go_new/l10n/app_localizations.dart';
import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/create_order_model.dart';
import 'package:taxi_go_new/models/trip_route_model.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

/// Pickup/dropoff are primarily picked on the real `GoogleMap` in
/// [MapPickerScreen]; the lat/lng fields stay manually editable as a
/// fallback (e.g. for emulators without a working Maps API key, or testers
/// who already know exact coordinates) - the map picker just fills them in.
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationService = LocationService();

  final _pickupLocationCtrl = TextEditingController();
  final _pickupLatCtrl = TextEditingController();
  final _pickupLngCtrl = TextEditingController();
  final _dropoffLocationCtrl = TextEditingController();
  final _dropoffLatCtrl = TextEditingController();
  final _dropoffLngCtrl = TextEditingController();

  int _passengerCount = 1;
  OrderPriorityType _priority = OrderPriorityType.normal;
  VehicleSize? _requiredVehicleSize;
  bool _specifyDropoff = false;
  bool _gettingLocation = false;
  bool _scheduleForLater = false;
  DateTime? _scheduledAt;

  Timer? _routeDebounce;
  TripRouteModel? _previewRoute;
  bool _loadingPreviewRoute = false;
  String? _lastRouteKey;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _pickupLatCtrl,
      _pickupLngCtrl,
      _dropoffLatCtrl,
      _dropoffLngCtrl,
    ]) {
      c.addListener(_onCoordsChanged);
    }
  }

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _pickupLocationCtrl.dispose();
    _pickupLatCtrl.dispose();
    _pickupLngCtrl.dispose();
    _dropoffLocationCtrl.dispose();
    _dropoffLatCtrl.dispose();
    _dropoffLngCtrl.dispose();
    super.dispose();
  }

  /// Debounced so the route isn't re-fetched on every keystroke while
  /// editing the (manually-editable, see class doc) lat/lng fields - only
  /// once typing/picking settles for 500ms.
  void _onCoordsChanged() {
    _routeDebounce?.cancel();
    _routeDebounce = Timer(
      const Duration(milliseconds: 500),
      _maybeLoadPreviewRoute,
    );
  }

  Future<void> _maybeLoadPreviewRoute() async {
    if (!_specifyDropoff) return;

    final pLat = double.tryParse(_pickupLatCtrl.text.trim());
    final pLng = double.tryParse(_pickupLngCtrl.text.trim());
    final dLat = double.tryParse(_dropoffLatCtrl.text.trim());
    final dLng = double.tryParse(_dropoffLngCtrl.text.trim());

    if (pLat == null || pLng == null || dLat == null || dLng == null) return;

    final key = '$pLat,$pLng,$dLat,$dLng';
    if (key == _lastRouteKey) return;
    _lastRouteKey = key;

    setState(() => _loadingPreviewRoute = true);

    try {
      final route = await context.read<OrderCubit>().orderRepository.previewRoute(
        pickupLat: pLat,
        pickupLng: pLng,
        dropoffLat: dLat,
        dropoffLng: dLng,
      );

      if (!mounted || key != _lastRouteKey) return;
      setState(() {
        _previewRoute = route;
        _loadingPreviewRoute = false;
      });
    } catch (_) {
      if (!mounted || key != _lastRouteKey) return;
      // Routing service unavailable - the map below falls back to a
      // straight line between the two points rather than showing nothing.
      setState(() {
        _previewRoute = TripRouteModel.empty;
        _loadingPreviewRoute = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      final position = await _locationService.getCurrentLocation();
      _pickupLatCtrl.text = position.latitude.toString();
      _pickupLngCtrl.text = position.longitude.toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _pickPickupOnMap() async {
    final currentLat = double.tryParse(_pickupLatCtrl.text.trim());
    final currentLng = double.tryParse(_pickupLngCtrl.text.trim());

    final result = await MapPickerScreen.pick(
      context,
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      title: AppLocalizations.of(context)!.createOrderSelectPickupLocation,
    );

    if (result == null) return;

    setState(() {
      _pickupLatCtrl.text = result.latitude.toString();
      _pickupLngCtrl.text = result.longitude.toString();
      if (result.address.isNotEmpty) {
        _pickupLocationCtrl.text = result.address;
      }
    });
  }

  Future<void> _pickDropoffOnMap() async {
    final currentLat = double.tryParse(_dropoffLatCtrl.text.trim());
    final currentLng = double.tryParse(_dropoffLngCtrl.text.trim());

    final result = await MapPickerScreen.pick(
      context,
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      title: AppLocalizations.of(context)!.createOrderSelectDropoffLocation,
    );

    if (result == null) return;

    setState(() {
      _dropoffLatCtrl.text = result.latitude.toString();
      _dropoffLngCtrl.text = result.longitude.toString();
      if (result.address.isNotEmpty) {
        _dropoffLocationCtrl.text = result.address;
      }
    });
  }

  Future<void> _pickScheduledDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now.add(const Duration(minutes: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final initialTime = _scheduledAt != null
        ? TimeOfDay.fromDateTime(_scheduledAt!)
        : TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30)));

    final time = await showTimePicker(context: context, initialTime: initialTime);
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    if (_scheduleForLater) {
      if (_scheduledAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.createOrderPickScheduleSnack)),
        );
        return;
      }

      if (_scheduledAt!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.createOrderScheduledPastSnack)),
        );
        return;
      }
    }

    final model = CreateOrderModel(
      pickupLat: double.parse(_pickupLatCtrl.text.trim()),
      pickupLng: double.parse(_pickupLngCtrl.text.trim()),
      pickupLocation: _pickupLocationCtrl.text.trim(),
      dropoffLat: _specifyDropoff
          ? double.parse(_dropoffLatCtrl.text.trim())
          : null,
      dropoffLng: _specifyDropoff
          ? double.parse(_dropoffLngCtrl.text.trim())
          : null,
      dropoffLocation: _specifyDropoff
          ? _dropoffLocationCtrl.text.trim()
          : null,
      priority: _priority,
      requiredVehicleSize: _requiredVehicleSize,
      passengerCount: _passengerCount,
      scheduledAt: _scheduleForLater ? _scheduledAt : null,
    );

    context.read<OrderCubit>().createOrder(model);
  }

  String? _requiredCoordValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) return l10n.commonRequired;
    if (double.tryParse(value.trim()) == null) return l10n.createOrderInvalidNumber;
    return null;
  }

  /// Shows pickup + dropoff markers and the real road route between them
  /// once both are picked. Falls back to a straight line only if the
  /// routing service couldn't be reached - never shown while a fetch is
  /// still in flight, so a slow response never flashes a wrong line before
  /// the real one arrives.
  Widget _buildRoutePreview() {
    final pLat = double.tryParse(_pickupLatCtrl.text.trim());
    final pLng = double.tryParse(_pickupLngCtrl.text.trim());
    final dLat = double.tryParse(_dropoffLatCtrl.text.trim());
    final dLng = double.tryParse(_dropoffLngCtrl.text.trim());

    if (pLat == null || pLng == null || dLat == null || dLng == null) {
      return const SizedBox.shrink();
    }

    final pickup = LatLng(pLat, pLng);
    final dropoff = LatLng(dLat, dLng);

    final route = _previewRoute;
    final hasRealRoute = route != null && route.hasRoute;
    final routePoints = hasRealRoute
        ? route.points.map((p) => LatLng(p.lat, p.lng)).toList()
        : (route != null ? [pickup, dropoff] : <LatLng>[]);

    return Stack(
      children: [
        TripRouteMap(pickup: pickup, dropoff: dropoff, routePoints: routePoints, height: 200),
        if (_loadingPreviewRoute)
          const Positioned(
            top: 8,
            right: 8,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderDetailLoaded) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: state.order.orderId),
            ),
          );
        }

        if (state is OrderFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is OrderLoading;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.createOrderTitle)),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppSectionHeader(title: l10n.commonPickup),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _pickupLocationCtrl,
                        label: l10n.createOrderPickupAddress,
                        prefixIcon: Icons.my_location,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.commonRequired
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _pickupLatCtrl,
                              label: l10n.commonLatitude,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: _requiredCoordValidator,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppTextField(
                              controller: _pickupLngCtrl,
                              label: l10n.commonLongitude,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: _requiredCoordValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          AppSecondaryButton(
                            label: l10n.createOrderPickOnMap,
                            icon: Icons.map_outlined,
                            expand: false,
                            onPressed: _pickPickupOnMap,
                          ),
                          TextButton.icon(
                            onPressed: _gettingLocation ? null : _useCurrentLocation,
                            icon: _gettingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: Text(l10n.createOrderUseCurrentLocation),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.createOrderSpecifyDropoffNow),
                  subtitle: Text(l10n.createOrderDropoffOptionalSubtitle),
                  value: _specifyDropoff,
                  onChanged: (value) => setState(() => _specifyDropoff = value),
                ),
                if (_specifyDropoff) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppSectionHeader(title: l10n.commonDropoff),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _dropoffLocationCtrl,
                          label: l10n.createOrderDropoffAddress,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (v) => _specifyDropoff &&
                                  (v == null || v.trim().isEmpty)
                              ? l10n.commonRequired
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _dropoffLatCtrl,
                                label: l10n.commonLatitude,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: _specifyDropoff
                                    ? _requiredCoordValidator
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(
                                controller: _dropoffLngCtrl,
                                label: l10n.commonLongitude,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: _specifyDropoff
                                    ? _requiredCoordValidator
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppSecondaryButton(
                          label: l10n.createOrderPickOnMap,
                          icon: Icons.map_outlined,
                          expand: false,
                          onPressed: _pickDropoffOnMap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildRoutePreview(),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.createOrderScheduleForLater),
                  subtitle: Text(
                    _scheduleForLater && _scheduledAt != null
                        ? '${l10n.createOrderPickupAt} ${_scheduledAt!.toLocal()}'.split('.').first
                        : l10n.createOrderScheduleOff,
                  ),
                  value: _scheduleForLater,
                  onChanged: (value) {
                    setState(() => _scheduleForLater = value);
                    if (value) _pickScheduledDateTime();
                  },
                ),
                if (_scheduleForLater) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    label: _scheduledAt == null
                        ? l10n.createOrderPickDateTime
                        : l10n.createOrderChangeDateTime,
                    icon: Icons.schedule,
                    expand: false,
                    onPressed: _pickScheduledDateTime,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                AppSectionHeader(title: l10n.createOrderTripPreferences),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.commonPassengers,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _passengerCount > 1
                                ? () => setState(() => _passengerCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_passengerCount',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: _passengerCount < 10
                                ? () => setState(() => _passengerCount++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<OrderPriorityType>(
                        initialValue: _priority,
                        decoration: InputDecoration(labelText: l10n.createOrderPriority),
                        items: [
                          DropdownMenuItem(
                            value: OrderPriorityType.normal,
                            child: Text(l10n.createOrderNormal),
                          ),
                          DropdownMenuItem(
                            value: OrderPriorityType.urgent,
                            child: Text(l10n.createOrderUrgent),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _priority = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<VehicleSize?>(
                        initialValue: _requiredVehicleSize,
                        decoration: InputDecoration(
                          labelText: l10n.createOrderVehicleSizeOptional,
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.createOrderAny)),
                          ...VehicleSize.values.map(
                            (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _requiredVehicleSize = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppPrimaryButton(
                  label: l10n.createOrderTitle,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
