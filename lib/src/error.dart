class MissingAuthorizationFailure implements Exception {
  MissingAuthorizationFailure();
}

class UnableToInitializeFailure implements Exception {
  final String? message;
  UnableToInitializeFailure([this.message]);
}
