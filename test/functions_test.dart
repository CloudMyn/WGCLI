// @Timeout(Duration(minutes: 3))

// ignore_for_file: non_constant_identifier_names

import 'package:cli/bootstrap.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  test('Image test', () async {
    String url =
        'https://www.luminousscans.com/wp-content/uploads/2021/09/02-52.png';

    Response<List<int>> resp = await Dio().get<List<int>>(url,
        options: Options(responseType: ResponseType.bytes));

    Image? image = decodeImage(resp.data!);

    if (image == null) throw 'Image is null';

    encodeJpg(image, quality: 50);

    "done".println();

    // ...
  });
}
