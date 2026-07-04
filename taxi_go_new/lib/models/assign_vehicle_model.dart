class AssignVehicleModel {
  final int vehicleId;
  final int driverId;

  const AssignVehicleModel({
    required this.vehicleId,
    required this.driverId,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'driverId': driverId,
    };
  }
}