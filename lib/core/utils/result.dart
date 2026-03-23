/// Result Type
///
/// A sealed class representing the result of an operation that can either
/// succeed or fail. This is used for functional error handling instead of
/// throwing exceptions.
///
/// Usage:
/// ```dart
/// Result<User> result = await fetchUser();
/// switch (result) {
///   case Success(data: final user):
///     print('User: ${user.name}');
///   case Failure(message: final msg):
///     print('Error: $msg');
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Success Result
///
/// Represents a successful operation result containing data of type T.
final class Success<T> extends Result<T> {
  /// The successful result data
  final T data;

  const Success(this.data);
}

/// Failure Result
///
/// Represents a failed operation result with an error message and optional error object.
final class Failure<T> extends Result<T> {
  /// Human-readable error message
  final String message;

  /// Optional error object for additional context
  final Object? error;

  const Failure(this.message, [this.error]);
}

