import 'package:cli/bootstrap.dart';

class WorkerError extends ThrowableE {
  WorkerError([message, StackTrace? s]) : super(message: message, stackTrace: s);
}

class WorkerException extends ThrowableX {
  WorkerException([message, StackTrace? s])
      : super(message: message, stackTrace: s);
}
