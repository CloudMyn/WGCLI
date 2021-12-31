import 'package:cli/bootstrap.dart';

class ScraperException extends ThrowableX {
  ScraperException(String msg, [StackTrace? st]) : super(message: msg, stackTrace: st);
}

class ScraperError extends ThrowableX {
  ScraperError(String msg, [StackTrace? st]) : super(message: msg, stackTrace: st);
}
