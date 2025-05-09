class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}

class DuplicateEntryException implements Exception {
  final String message;

  DuplicateEntryException(this.message);

  @override
  String toString() => 'DuplicateEntryException: $message';
}

class QuotaExceededException implements Exception {
  final String message;

  QuotaExceededException(this.message);

  @override
  String toString() => 'QuotaExceededException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class QueryException implements Exception {
  final String message;

  QueryException(this.message);

  @override
  String toString() => 'QueryException: $message';
}

class ConcurrencyException implements Exception {
  final String message;

  ConcurrencyException(this.message);

  @override
  String toString() => 'ConcurrencyException: $message';
}

class InvalidStateException implements Exception {
  final String message;

  InvalidStateException(this.message);

  @override
  String toString() => 'InvalidStateException: $message';
}

class DependencyException implements Exception {
  final String message;

  DependencyException(this.message);

  @override
  String toString() => 'DependencyException: $message';
}

class ProtectedResourceException implements Exception {
  final String message;

  ProtectedResourceException(this.message);

  @override
  String toString() => 'ProtectedResourceException: $message';
}
