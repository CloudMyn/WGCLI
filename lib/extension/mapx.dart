// ignore_for_file: unnecessary_this

import 'dart:math';

extension MapX on Map<String, List<dynamic>> {
  List<String> toListx() {
    Iterable<MapEntry<String, dynamic>> iter = this.entries;

    List<String> list = [];

    for (MapEntry<String, dynamic> mapEntry in iter) {
      list = mapEntry.value;
    }

    return list;
  }
}
