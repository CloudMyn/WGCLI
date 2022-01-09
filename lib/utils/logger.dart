// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:io';

import 'package:colorize/colorize.dart';
import 'package:path/path.dart';

enum LogStack { warning, error, info, debug, banner }

void log(
  String title,
  Object data, {
  LogStack logStack = LogStack.debug,
  int extendDivider = 4,
  String dividerChar = '-',
}) {
  List<String> strings = title.split("\n");
  List<String> newStrings = [];

  String prevstr = '';
  String choosed = '';

  for (var str in strings) {
    str = str.trim();

    newStrings.add(str);

    // get the longest string in the list
    if (str.length > prevstr.length && str.length > choosed.length) {
      choosed = str;
    }

    prevstr = str;
  }

  // Alignment center
  newStrings = centerAligment(newStrings, choosed.length, extendDivider);

  String divider = generateDivider(
    choosed,
    divider: dividerChar,
    extend: extendDivider,
  );

  String text = '';

  text += divider + "\n";
  text += newStrings.join('\n') + '\n';
  text += divider + "\n";

  logc("\n" + text, logStack);
  logc((" " * 2) + data.toString(), logStack);
  logc(text, logStack);
}

void logc(String text, LogStack logStack, [bool isBold = false]) {
  Styles estyle = Styles.WHITE;
  switch (logStack) {
    case LogStack.warning:
      estyle = Styles.LIGHT_YELLOW;
      break;
    case LogStack.error:
      estyle = Styles.LIGHT_RED;
      break;
    case LogStack.info:
      estyle = Styles.LIGHT_BLUE;
      break;
    case LogStack.debug:
      estyle = Styles.WHITE;
      break;
    case LogStack.banner:
      estyle = Styles.LIGHT_GREEN;
      break;
  }
  color(text, front: estyle, isBold: isBold);
}

String generateDivider(String str, {String divider = '-', int extend = 2}) {
  String line = '';

  for (int i = 1; i <= str.length + extend; i++) {
    line += divider;
  }

  return line;
}

List<String> centerAligment(
  List<String> strings,
  int mxstrlen,
  int dividerExtend,
) {
  int dividerLength = mxstrlen + dividerExtend;

  List<String> ns = [];

  for (var str in strings) {
    str = str.trim();

    int rx = dividerLength - str.length;
    int ws = (rx / 2).floor();

    String char = "";

    for (int x = 1; x <= ws; x++) {
      char += ' ';
    }

    ns.add(char + str);
  }

  return ns;
}

Future<String> logListting(List<dynamic> data) async {
  String chaptersListLog = "";
  int index = 0;

  for (var chp in data) {
    if (chp is String) {
      String title = lastURL(chp);
      chaptersListLog += "\t[$index] \t $title \n";
      index++;
    } else if (chp is Map) {
      Iterable<MapEntry<dynamic, dynamic>> iter = chp.entries;

      await Future.forEach(iter, (MapEntry me) async {
        String key = me.key as String;
        List<String> value = me.value as List<String>;

        chaptersListLog += (" " * 2) + lastURL(key) + '\n';

        for (String imgUrl in value) {
          chaptersListLog += (" " * 4) + lastURL(imgUrl) + '\n';
        }

        index++;
      });
    }
  }

  return chaptersListLog;
}

String lastURL(String url) {
  String char = '\\';
  if (url.contains('/')) char = '/';
  return url.replaceAll(char, ' ').trim().split(' ').last;
}
