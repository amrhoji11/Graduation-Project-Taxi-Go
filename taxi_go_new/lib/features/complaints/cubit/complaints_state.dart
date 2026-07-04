part of 'complaints_cubit.dart';

abstract class ComplaintsState {
  const ComplaintsState();
}

class ComplaintsInitial extends ComplaintsState {
  const ComplaintsInitial();
}

class ComplaintsLoading extends ComplaintsState {
  const ComplaintsLoading();
}

class ComplaintsLoaded extends ComplaintsState {
  final List<ComplaintModel> complaints;

  const ComplaintsLoaded({
    required this.complaints,
  });
}

class AdminComplaintsLoaded extends ComplaintsState {
  final List<AdminComplaintModel> complaints;

  const AdminComplaintsLoaded({
    required this.complaints,
  });
}

class ViolationsLoaded extends ComplaintsState {
  final List<ViolationModel> violations;

  const ViolationsLoaded({
    required this.violations,
  });
}

class ComplaintsSuccess extends ComplaintsState {
  final String message;

  const ComplaintsSuccess({
    required this.message,
  });
}

class ComplaintsFailure extends ComplaintsState {
  final String message;

  const ComplaintsFailure({
    required this.message,
  });
}