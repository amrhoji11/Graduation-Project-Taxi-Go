import '../models/driver_model.dart';

final List<DriverModel> fakeDrivers = [
  DriverModel(
    userId: '1',
    name: 'Ahmad Ali',
    phone: '0599000001',
    status: DriverStatus.available,
  ),
  DriverModel(
    userId: '2',
    name: 'Mohammad Saleh',
    phone: '0599000002',
    status: DriverStatus.offline,
  ),
];
