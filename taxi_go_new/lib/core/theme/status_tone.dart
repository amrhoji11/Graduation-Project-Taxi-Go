import 'package:taxi_go_new/core/theme/app_colors.dart';
import 'package:taxi_go_new/models/admin_enums.dart';
import 'package:taxi_go_new/models/complaint_enums.dart';
import 'package:taxi_go_new/models/driver_active_state_model.dart';
import 'package:taxi_go_new/models/driver_model.dart';

/// Maps backend status enums onto a semantic [AppStatusTone] for
/// [AppStatusChip] - kept in one place so every screen colors the same
/// status the same way instead of each screen re-deriving it.
AppStatusTone orderStatusTone(OrderStatusType status) {
  switch (status) {
    case OrderStatusType.completed:
      return AppStatusTone.success;
    case OrderStatusType.cancelled:
      return AppStatusTone.error;
    case OrderStatusType.noDriverFound:
    case OrderStatusType.pendingOfficeReview:
      return AppStatusTone.warning;
    case OrderStatusType.pending:
    case OrderStatusType.searchingDriver:
    case OrderStatusType.assignedToTrip:
    case OrderStatusType.unknown:
      return AppStatusTone.info;
  }
}

AppStatusTone tripStatusTone(TripStatusType status) {
  switch (status) {
    case TripStatusType.completed:
      return AppStatusTone.success;
    case TripStatusType.cancelled:
    case TripStatusType.noDriverFound:
      return AppStatusTone.error;
    case TripStatusType.pending:
    case TripStatusType.searchingDriver:
      return AppStatusTone.warning;
    case TripStatusType.assigned:
    case TripStatusType.driverArrived:
    case TripStatusType.inProgress:
    case TripStatusType.unknown:
      return AppStatusTone.info;
  }
}

AppStatusTone tripOrderStatusTone(TripOrderStatusType status) {
  switch (status) {
    case TripOrderStatusType.droppedOff:
      return AppStatusTone.success;
    case TripOrderStatusType.cancelled:
    case TripOrderStatusType.unassigned:
      return AppStatusTone.error;
    case TripOrderStatusType.assigned:
    case TripOrderStatusType.driverArrived:
    case TripOrderStatusType.pickedUp:
      return AppStatusTone.info;
  }
}

AppStatusTone complaintStatusTone(ComplaintStatusType status) {
  switch (status) {
    case ComplaintStatusType.resolved:
      return AppStatusTone.success;
    case ComplaintStatusType.rejected:
      return AppStatusTone.error;
    case ComplaintStatusType.inReview:
      return AppStatusTone.warning;
    case ComplaintStatusType.pending:
    case ComplaintStatusType.unknown:
      return AppStatusTone.info;
  }
}

AppStatusTone driverStatusTone(DriverStatus status) {
  switch (status) {
    case DriverStatus.available:
    case DriverStatus.busy:
    case DriverStatus.shared:
      return AppStatusTone.success;
    case DriverStatus.returningToOffice:
      return AppStatusTone.warning;
    case DriverStatus.rejected:
      return AppStatusTone.error;
    case DriverStatus.offline:
    case DriverStatus.unknown:
      return AppStatusTone.neutral;
  }
}

AppStatusTone violationStatusTone(ViolationStatusType status) {
  return status == ViolationStatusType.resolved
      ? AppStatusTone.success
      : AppStatusTone.warning;
}
