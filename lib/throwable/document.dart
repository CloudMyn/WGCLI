import 'package:cli/bootstrap.dart';

class DocumentError extends ThrowableE {
  DocumentError([message, StackTrace? s])
      : super(message: message, stackTrace: s);
}

class DocumentException extends ThrowableX {
  DocumentException([message, StackTrace? s])
      : super(message: message, stackTrace: s);
}
