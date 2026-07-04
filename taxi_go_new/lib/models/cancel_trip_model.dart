/// Mirrors backend `TripCancelReason` (TaxiApp.Backend.Core.Models.Enums) -
/// sent/received as a raw int, there is no JsonStringEnumConverter on the
/// backend.
enum TripCancelReason {
  driverIssue,
  vehicleProblem,
  accident,
  emergency;

  int get apiValue => index;

  String get label {
    switch (this) {
      case TripCancelReason.driverIssue:
        return 'Driver issue';
      case TripCancelReason.vehicleProblem:
        return 'Vehicle problem';
      case TripCancelReason.accident:
        return 'Accident';
      case TripCancelReason.emergency:
        return 'Emergency';
    }
  }
}

class CancelTripModel {
  final TripCancelReason reason;

  const CancelTripModel({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason.apiValue};
  }
}
