import 'package:cli/throwable/throwable.dart';

class RuntimeException extends ThrowableX {
  RuntimeException([message, strace]) : super(message: message, stackTrace: strace);
}

class RuntimeError extends ThrowableE {
  RuntimeError([message, strace]) : super(message: message, stackTrace: strace);
}
