// ignore_for_file: unnecessary_this

import 'package:colorize/colorize.dart';

extension MapPrint on Map<String, dynamic> {
  void println() {
    forEach((key, value) {
      print("$key : $value");
    });
  }
}

extension ListPrint on List<dynamic> {
  void println() {
    forEach((value) {
      print("$value");
    });
  }
}

extension StrPrint on String {
  void println([Styles? fontColor]) {
    color(this, front: fontColor);
  }
}

extension IntPrint on int {
  void println() {
    print(this.toString());
  }
}

extension DoublePrint on double {
  void println() {
    print(this.toString());
  }
}
