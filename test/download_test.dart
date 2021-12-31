@Timeout(Duration(minutes: 10))

import 'package:cli/bootstrap.dart';
import 'package:test/test.dart';

void main() {
  test('Test multiple downloading using isolates', () async {
    List<String> links = [
      'https://www.asurascans.com/wp-content/uploads/2021/12/01-372.jpg',
      'https://www.asurascans.com/wp-content/uploads/2021/12/01-372.jpg',
      'http://localhost:8080/Super-Evolution-Chapter-31_files/03-284-1.jpg',
      'http://localhost:8080/Super-Evolution-Chapter-31_files/03-284-1.jpg',
    ];

    List<String> paths = [
      './data-test/',
      './data-test/',
      './data-test/',
      './data-test/',
    ];

    IsolateHandler ish = IsolateHandler();

    // ish.compute();

    // ...
  });
}


Future<void> tot() async{
  print('Noop');
}