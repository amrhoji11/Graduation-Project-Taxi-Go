/// Enum helpers matching `TaxiApp.Backend.Core.Models.Complaint.cs`
/// (raw integer values - no `JsonStringEnumConverter` configured globally).
library;

enum ComplaintStatusType {
  pending,
  inReview,
  resolved,
  rejected,
  unknown;

  static ComplaintStatusType fromValue(dynamic value) {
    if (value is int && value >= 0 && value < ComplaintStatusType.values.length - 1) {
      return ComplaintStatusType.values[value];
    }
    return ComplaintStatusType.unknown;
  }

  String get label {
    switch (this) {
      case ComplaintStatusType.pending:
        return 'Pending';
      case ComplaintStatusType.inReview:
        return 'In Review';
      case ComplaintStatusType.resolved:
        return 'Resolved';
      case ComplaintStatusType.rejected:
        return 'Rejected';
      case ComplaintStatusType.unknown:
        return 'Unknown';
    }
  }
}

enum ComplaintReasonType {
  behavior,
  delay,
  cancellation,
  paymentIssue,
  routeIssue,
  other,
  unknown;

  static ComplaintReasonType fromValue(dynamic value) {
    if (value is int && value >= 0 && value < ComplaintReasonType.values.length - 1) {
      return ComplaintReasonType.values[value];
    }
    return ComplaintReasonType.unknown;
  }

  String get label {
    switch (this) {
      case ComplaintReasonType.behavior:
        return 'Behavior';
      case ComplaintReasonType.delay:
        return 'Delay';
      case ComplaintReasonType.cancellation:
        return 'Cancellation';
      case ComplaintReasonType.paymentIssue:
        return 'Payment Issue';
      case ComplaintReasonType.routeIssue:
        return 'Route Issue';
      case ComplaintReasonType.other:
        return 'Other';
      case ComplaintReasonType.unknown:
        return 'Unknown';
    }
  }
}

enum ComplaintTargetTypeEnum {
  driver,
  passenger,
  trip,
  unknown;

  static ComplaintTargetTypeEnum fromValue(dynamic value) {
    if (value is int && value >= 0 && value < ComplaintTargetTypeEnum.values.length - 1) {
      return ComplaintTargetTypeEnum.values[value];
    }
    return ComplaintTargetTypeEnum.unknown;
  }

  String get label {
    switch (this) {
      case ComplaintTargetTypeEnum.driver:
        return 'Driver';
      case ComplaintTargetTypeEnum.passenger:
        return 'Passenger';
      case ComplaintTargetTypeEnum.trip:
        return 'Trip';
      case ComplaintTargetTypeEnum.unknown:
        return 'Unknown';
    }
  }
}

enum ViolationStatusType {
  active,
  resolved,
  unknown;

  static ViolationStatusType fromValue(dynamic value) {
    if (value == 0) return ViolationStatusType.active;
    if (value == 1) return ViolationStatusType.resolved;
    return ViolationStatusType.unknown;
  }

  String get label => this == ViolationStatusType.resolved ? 'Resolved' : 'Active';
}

enum ViolationTypeEnum {
  behavior,
  delay,
  cancellation,
  unknown;

  static ViolationTypeEnum fromValue(dynamic value) {
    if (value is int && value >= 0 && value < ViolationTypeEnum.values.length - 1) {
      return ViolationTypeEnum.values[value];
    }
    return ViolationTypeEnum.unknown;
  }

  String get label {
    switch (this) {
      case ViolationTypeEnum.behavior:
        return 'Behavior';
      case ViolationTypeEnum.delay:
        return 'Delay';
      case ViolationTypeEnum.cancellation:
        return 'Cancellation';
      case ViolationTypeEnum.unknown:
        return 'Unknown';
    }
  }
}
