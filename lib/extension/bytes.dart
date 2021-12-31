import 'dart:typed_data';

extension Bytes on List<Uint8List> {

  /// Method for converting `List<Uint8List>` to `List<int>`
  /// return `List<int>`
  List<int> convertToBytes() {
    List<int> bytes = [];

    for (Uint8List ui8 in this) {
      for (int byte in ui8) {
        bytes.add(byte);
      }
    }

    return bytes;
  }
}
