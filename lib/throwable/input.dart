import 'package:cli/bootstrap.dart';

class InputError extends ThrowableE {
  InputError([message, StackTrace? s]) : super(message: message, stackTrace: s);
}

class InputException extends ThrowableX {
  InputException([message, StackTrace? s])
      : super(message: message, stackTrace: s);
}
