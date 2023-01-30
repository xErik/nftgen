/// Returned by the CLI conveying an error message for
/// invocating packages.
///
/// Is returned when not being called on the CLI.
abstract class NftException implements Exception {
  String message;
  NftException(this.message);
}

/// Generic exception.
class NftCliException extends NftException {
  NftCliException(String message) : super(message);
}

/// Not enough free disk space.
class NftNotEnoughFreespaceException extends NftException {
  NftNotEnoughFreespaceException(String message) : super(message);
}

/// In case a stop signal has been received (from a GUI etc).
class NftStopException extends NftException {
  NftStopException(String message) : super(message);
}

/// File not found exception.
class NftFileNotFoundException extends NftException {
  NftFileNotFoundException(String message) : super(message);
}

/// Folder not found exception.
class NftFolderNotFoundException extends NftException {
  NftFolderNotFoundException(String message) : super(message);
}
