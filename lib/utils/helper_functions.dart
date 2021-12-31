import 'package:cli/bootstrap.dart';

Object? ask(String message,
    {bool require = false, String? errMsg, String? defaultValue}) {
  stdout.write(message);
  String response = stdin.readLineSync() ?? '';

  if (response.isEmpty && require && defaultValue == null) {
    throw ValidationError(errMsg ?? 'required parameter is null');
  }

  if (response.isEmpty && defaultValue != null) {
    response = defaultValue;
  }

  return response;
}

bool askExit() {
  String quit = ask(
    "Do yo want to exit? (Y/N)[Y] : ",
    require: true,
    defaultValue: 'y',
  )!
      .toString()
      .toLowerCase();

  "".println();

  return (quit == 'y' || quit == 'yes') ? true : false;
}

// Replace '/' separator to actual OS path separator
String replaceSp(String str) => str.replaceAll('/', Platform.pathSeparator);
