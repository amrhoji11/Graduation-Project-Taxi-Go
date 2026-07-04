class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    required super.message,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    required super.message,
  }) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.message,
  }) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
  }) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
  }) : super(statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException({
    required super.message,
  }) : super(statusCode: 500);
}