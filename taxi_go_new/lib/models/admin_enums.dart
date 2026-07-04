/// Shared enum helpers for Admin screens (Orders/Trips reports).
/// The backend serializes C# enums as raw integers by default
/// (no global `JsonStringEnumConverter` is configured in `Program.cs`),
/// so these map the integer values exactly as declared in
/// `TaxiApp.Backend.Core.Models.Enums.cs` / `Order.cs` / `Trip.cs`.
library;

enum OrderStatusType {
  pending,
  searchingDriver,
  pendingOfficeReview,
  assignedToTrip,
  cancelled,
  completed,
  noDriverFound,
  unknown;

  static OrderStatusType fromValue(dynamic value) {
    if (value is int && value >= 0 && value < OrderStatusType.values.length - 1) {
      return OrderStatusType.values[value];
    }
    return OrderStatusType.unknown;
  }

  String get label {
    switch (this) {
      case OrderStatusType.pending:
        return 'Pending';
      case OrderStatusType.searchingDriver:
        return 'Searching Driver';
      case OrderStatusType.pendingOfficeReview:
        return 'Pending Office Review';
      case OrderStatusType.assignedToTrip:
        return 'Assigned To Trip';
      case OrderStatusType.cancelled:
        return 'Cancelled';
      case OrderStatusType.completed:
        return 'Completed';
      case OrderStatusType.noDriverFound:
        return 'No Driver Found';
      case OrderStatusType.unknown:
        return 'Unknown';
    }
  }
}

enum OrderPriorityType {
  normal,
  urgent,
  unknown;

  static OrderPriorityType fromValue(dynamic value) {
    if (value == 0) return OrderPriorityType.normal;
    if (value == 1) return OrderPriorityType.urgent;
    return OrderPriorityType.unknown;
  }

  String get label => this == OrderPriorityType.urgent ? 'Urgent' : 'Normal';
}

enum TripStatusType {
  pending,
  assigned,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  searchingDriver,
  noDriverFound,
  unknown;

  static TripStatusType fromValue(dynamic value) {
    if (value is int && value >= 0 && value < TripStatusType.values.length - 1) {
      return TripStatusType.values[value];
    }
    return TripStatusType.unknown;
  }

  String get label {
    switch (this) {
      case TripStatusType.pending:
        return 'Pending';
      case TripStatusType.assigned:
        return 'Assigned';
      case TripStatusType.driverArrived:
        return 'Driver Arrived';
      case TripStatusType.inProgress:
        return 'In Progress';
      case TripStatusType.completed:
        return 'Completed';
      case TripStatusType.cancelled:
        return 'Cancelled';
      case TripStatusType.searchingDriver:
        return 'Searching Driver';
      case TripStatusType.noDriverFound:
        return 'No Driver Found';
      case TripStatusType.unknown:
        return 'Unknown';
    }
  }
}
