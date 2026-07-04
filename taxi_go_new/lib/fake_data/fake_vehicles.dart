import '../models/vehicle_model.dart';

final List<VehicleModel> fakeVehicles = [
  VehicleModel(
    id: 1,
    driverId: '1',
    plateNumber: '30-123-45',
    make: 'Toyota',
    model: 'Corolla',
    color: 'White',
    isActive: true,
  ),
  VehicleModel(
    id: 2,
    driverId: '2',
    plateNumber: '40-555-22',
    make: 'Hyundai',
    model: 'Elantra',
    color: 'Black',
    isActive: false,
  ),
  VehicleModel(
    id: 3,
    driverId: null,
    plateNumber: '50-777-90',
    make: 'Kia',
    model: 'Rio',
    color: 'Silver',
    isActive: true,
  ),
];
