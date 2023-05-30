/// Call init() method without User has granted permission.
class MissingAuthorizationFailure implements Exception {
  MissingAuthorizationFailure();
}

///Unable to initialize phone state background plugin.
class UnableToInitializeFailure implements Exception {
  final String? message;
  UnableToInitializeFailure([this.message]);
}
