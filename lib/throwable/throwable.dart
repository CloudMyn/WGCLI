// ignore_for_file: unnecessary_this

class ThrowableE implements Error {
  late StackTrace? _stackTrace;
  final String? message;

  ThrowableE({this.message, StackTrace? stackTrace}) {
    this._stackTrace = stackTrace;
  }

  @override
  StackTrace? get stackTrace => _stackTrace;

  @override
  String toString() => this.message ?? 'No message available';
}

class ThrowableX implements Exception {
  late StackTrace? stackTrace;
  final String? message;

  ThrowableX({this.message, this.stackTrace});

  @override
  String toString() => this.message ?? 'No message available';
}
