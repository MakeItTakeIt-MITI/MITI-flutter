abstract class ErrorBase {
  final int status_code;
  final int error_code;

  ErrorBase({
    required this.status_code,
    required this.error_code,
  });

}