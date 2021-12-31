import 'package:cli/bootstrap.dart';

class Worker {
  late final ComicScraper web;

  Worker.assign(this.web);

  Future<bool> runTask(Future<bool> Function(ComicScraper) task) async {
    try {
      return await task.call(web);
    } on ThrowableX {
      rethrow;
    } on ThrowableE {
      rethrow;
    } catch (e) {
      return false;
    }
  }
}
