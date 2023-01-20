/// Returned by the CLI conveying an error message for
/// invocating packages.
///
/// Is returned when not being called on the CLI.
abstract class NftException {
  String message;
  NftException(this.message);
}

class NftCliException extends NftException {
  NftCliException(String message) : super(message);
}

class NftStopException extends NftException {
  NftStopException(String message) : super(message);
}

class NftFileNotFoundException extends NftException {
  NftFileNotFoundException(String message) : super(message);
}

class NftFolderNotFoundException extends NftException {
  NftFolderNotFoundException(String message) : super(message);
}
