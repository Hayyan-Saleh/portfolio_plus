class AppException implements Exception {
  final String message;

  const AppException({required this.message});
}

class AuthExceptiuon extends AppException {
  AuthExceptiuon({required super.message});
}

class OfflineException extends AppException {
  OfflineException({required super.message});
}

class OnlineException extends AppException {
  OnlineException({required super.message});
}
