// ignore_for_file: non_constant_identifier_names

import 'package:cli/bootstrap.dart';

class App {
  static String get fd_name => replaceSp("./data");

  static String get root_directory => replaceSp("./");

  static String rawpage_directory([String? pagename]) =>
      replaceSp("./rawpage/$pagename");
}
