import 'dart:isolate';

import 'package:cli/extension/print.dart';

class IsolateHandler {
  Isolate? isolate;
  final ReceivePort port = ReceivePort();

  Future<void> compute(
      Future<void> Function(List<String>) task, List<String> data) async {
    "Entered compute method.".println();

    var iscom = IsCom(task, port.sendPort, data);

    "Spawning an isolate.".println();

    Isolate isolate = await Isolate.spawn(isolate2, iscom);

    await for (var rspdata in port) {
      "Waiting response from spawned isolate.".println();

      if (rspdata == 'completed') {
        "Isolate spawned response is completed.".println();
        isolate.kill();
        break;
      }
    }
  }

  static void isolate2(IsCom isCom) async {
    "Spawnned Isolate is running task".println();

    await isCom.task.call(isCom.data);

    "Spawnned Isolate task is done.".println();

    isCom.sendPort.send("completed");
  }
}

class IsCom {
  SendPort sendPort;
  List<String> data;
  Future<void> Function(List<String> data) task;

  IsCom(this.task, this.sendPort, this.data);
}
