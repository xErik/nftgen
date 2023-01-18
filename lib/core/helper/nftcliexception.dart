/// Returned by the CLI conveying an error message for
/// invocating packages.
///
/// Is returned when not being called on the CLI.
class NftCliException {
  String message;
  NftCliException(this.message);
}
