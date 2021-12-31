// ignore_for_file: unused_import, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:cli/main.dart' as cli;
import 'package:cli/bootstrap.dart';
import 'package:cli/services/filesystem_handler.dart';

void main(List<String> arguments) {
  try {
    cli.main(arguments);
  } catch (e) {
    const string =
        """
    -----------------------------
    unexpected error has occurred
    -----------------------------
    """;
    stdout.writeln(string.toUpperCase());
    color(e.toString(), front: Styles.RED, isBold: true);
  }
}
