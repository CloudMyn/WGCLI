// ignore_for_file: unused_import, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:args/args.dart';
import 'package:cli/bootstrap.dart';
import 'package:cli/runtime.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';

void main(List<String> arguments) async {
  bool checkRuntime = false;

  banner();

  do {
    checkRuntime = await runtime_cli();
  } while (checkRuntime != true);

  "Start: re/generating fresh directory".println(Styles.YELLOW);

  FSHandler fsHandler = FSHandler();

  await fsHandler.genDataDirectory();

  "Done: generating completed successfuly".println(Styles.GREEN);
}
