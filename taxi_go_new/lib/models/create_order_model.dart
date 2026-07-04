import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/vehicle_model.dart';

/// Matches `CreateOrderDto` (`POST /Orders/CreateOrder`).
class CreateOrderModel {
  final double pickupLat;
  final double pickupLng;
  final String pickupLocation;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffLocation;
  final OrderPriorityType priority;
  final VehicleSize? requiredVehicleSize;
  final int passengerCount;
  final DateTime? scheduledAt;

  const CreateOrderModel({
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupLocation,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffLocation,
    this.priority = OrderPriorityType.normal,
    this.requiredVehicleSize,
    required this.passengerCount,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupLocation': pickupLocation,
      if (dropoffLat != null) 'dropoffLat': dropoffLat,
      if (dropoffLng != null) 'dropoffLng': dropoffLng,
      if (dropoffLocation != null) 'dropoffLocation': dropoffLocation,
      'priority': priority.index,
      if (requiredVehicleSize != null)
        'requiredVehicleSize': requiredVehicleSize!.apiValue,
      'passengerCount': passengerCount,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    };
  }
}
