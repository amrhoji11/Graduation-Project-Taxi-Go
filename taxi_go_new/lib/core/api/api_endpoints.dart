class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://192.168.1.12:7022/api';
  static const String registerPassenger = '/Account/registerPassenger';
  static const String confirmRegisterPassenger =
      '/Account/confirm-register-passenger';

  static const String registerDriver = '/Account/registerDriver';
  static const String confirmRegisterDriver =
      '/Account/confirm-register-driver';

  static const String login = '/Account/login';
  static const String verifyOtp = '/Account/verify-otp';
  static const String requestChangePhone = '/Account/request-change-phone';
  static const String confirmChangePhone = '/Account/confirm-change-phone';
  static const String refreshToken = '/Account/refresh-token';
  static const String logout = '/Account/logout';

  // Orders
  static const String createOrder = '/Orders/CreateOrder';
  static const String orders = '/Orders/GetAll';
  static String orderById(int id) => '/Orders/$id';
  static String updateOrder(int id) => '/Orders/$id';
  static String cancelOrder(int id) => '/Orders/$id/Cancel';
  static const String previewRoute = '/Orders/PreviewRoute';

  // Driver Trips
  static String acceptOrder(int orderId) =>
      '/DriverTrips/accept-order/$orderId';

  static String rejectOrder(int orderId) =>
      '/DriverTrips/reject-order/$orderId';

  static String arrived(int orderId) => '/DriverTrips/arrived/$orderId';

  static String startTrip(int tripId) => '/DriverTrips/start-trip/$tripId';

  static String pickupPassenger(int orderId) => '/DriverTrips/pickup/$orderId';

  static String dropOffPassenger(int orderId) =>
      '/DriverTrips/dropoff/$orderId';

  static String cancelTrip(int tripId) => '/DriverTrips/cancel-trip/$tripId';

  static const String enterQueue = '/DriverTrips/enter-queue';
  static const String leaveQueue = '/DriverTrips/leave-queue';
  static const String returnToOffice = '/DriverTrips/return-to-office';
  static const String driverActiveState = '/DriverTrips/active';

  static String driverTripRoute(int tripId) => '/DriverTrips/route/$tripId';

  // Vehicles
  static const String vehicles = '/Vehicles/GetAll';
  static String vehicleById(int id) => '/Vehicles/$id';
  static const String addVehicle = '/Vehicles/AddVehicle';
  static String editVehicle(int id) => '/Vehicles/$id/Edit';
  static const String unassignedVehicles = '/Vehicles/GetUnassignedAsync';

  static String unassignVehicle(int vehicleId) =>
      '/Vehicles/$vehicleId/Unassign';

  static String changeVehicleStatus(int vehicleId) =>
      '/Vehicles/$vehicleId/status';

  static String assignVehicle(int vehicleId) =>
      '/Vehicles/AssignVehicleToDriver/$vehicleId';

  // Admin
  static const String adminProfile = '/Admin/profile';
  static const String editAdminProfile = '/Admin/edit';
  static const String adminDrivers = '/Admin/GetAllDrivers';
  static const String approvedDrivers = '/Admin/GetApprovedDrivers';
  static const String adminPassengers = '/Admin/GetAllPassengers';
  static const String adminOrders = '/Admin/orders';
  static const String adminTrips = '/Admin/trips';
  static const String adminCurrentTrips = '/Admin/CurrentTrips';
  static const String topDrivers = '/Admin/top-drivers';

  static String adminProfileById(String id) => '/Admin/profile/$id';

  static String softDeleteDriver(String id) => '/Admin/SoftDeleteDriver/$id';

  static String restoreDriver(String id) => '/Admin/RestoreDriver/$id';

  static String softDeletePassenger(String id) =>
      '/Admin/SoftDeletePassenger/$id';

  static String restorePassenger(String id) => '/Admin/RestorePassenger/$id';

  // Users / account status (activate-deactivate, block-unblock)
  static String toggleUserActive(String userId) =>
      '/Users/ToggleUserActive/$userId';

  static String toggleUserBlock(String userId) =>
      '/UserBlocks/$userId/ToggleUserBlock';

  static const String allBlocks = '/UserBlocks/GetAllBlocks';

  // Manual driver assignment
  static String manualAssignOrder(int orderId) =>
      '/DriverAssignmentManual/manual-assign-order/$orderId';

  static const String assignableDrivers =
      '/DriverAssignmentManual/assignable-drivers';

  // Driver Approvals
  static const String pendingDrivers = '/DriverApprovals/pending';

  static String approveDriver(String id) => '/DriverApprovals/approve/$id';

  static String rejectDriver(String id) => '/DriverApprovals/reject/$id';

  static String driverApprovalDetails(String driverId) =>
      '/DriverApprovals/$driverId';

  // Settings
  static const String language = '/Settings/Language';
  static const String getLanguage = '/Settings/language';

  static const String darkMode = '/Settings/darkmode';
  static const String getDarkMode = '/Settings/darkmode';

  static const String notificationsStatus = '/Settings/Notifications';
  static const String viewNotificationsStatus =
      '/Settings/ViewNotificationsStatus';

  static const String whatsappContact = '/Settings/ContactWithTaxiGo';

  // Notifications
  static const String notifications = '/Notifications';

  static String markNotificationAsRead(int id) =>
      '/Notifications/mark-as-read/$id';

  static const String markAllNotificationsAsRead =
      '/Notifications/mark-all-read';

  // Favorite Locations
  static const String addFavoriteLocation =
      '/FavoriteLocations/AddFavoriteLocation';

  static const String favoriteLocations =
      '/FavoriteLocations/GetAllFavoriteLocations';

  static String deleteFavoriteLocation(int locationId) =>
      '/FavoriteLocations/DeleteFavoriteLocation/$locationId';

  // Complaints
  static String createComplaint(int orderId) => '/orders/$orderId/complaints';

  static const String complaints = '/Complaints/all';

  static String updateComplaintStatus(int complaintId) =>
      '/Complaints/update-status/$complaintId';

  static const String violations = '/Complaints/violations';

  static String resolveViolation(int id) =>
      '/Complaints/violations/$id/resolve';

  static String driverViolationsCount(int driverId) =>
      '/Complaints/driver/$driverId/violations-count';

  // Reports
  static const String driverTripsReport = '/Drivers/my-trips-report';
  static const String passengerTripsReport = '/Passengers/trips-report';

  // Passenger / Driver Profile
  static const String passengerProfile = '/Passengers/profile';
  static const String updatePassengerProfile = '/Passengers/update-profile';
  static const String driverProfile = '/Drivers/profile';
  static const String updateDriverProfile = '/Drivers/update-profile';

  // Passenger Trips
  static const String rateDriver = '/PassengerTrips/rate-driver';

  static String passengerTripRoute(int orderId) =>
      '/PassengerTrips/route/$orderId';
}
