import 'package:cli/bootstrap.dart';

class ValidationError extends ThrowableX {
  ValidationError([message, StackTrace? s])
      : super(message: message, stackTrace: s);
}
