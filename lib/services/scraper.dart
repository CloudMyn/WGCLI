// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_new

import 'dart:typed_data';

import 'package:cli/bootstrap.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';
import 'package:web_scraper/web_scraper.dart';

class Scraper {
  late final WebScraper scraper;

  int? _execStart, _execEnd;

  int get execStart => _execStart ?? 0;

  int get execEnd => _execEnd ?? 0;

  Scraper([String? origin]) {
    scraper = new WebScraper(origin);
  }

  Future<List<Map<String, dynamic>>> scrapeWeb({
    required String webURL,
    required String selector,
    required List<String> attributes,
  }) async {
    bool result = await scraper.loadFullURL(webURL);

    if (!result) throw ScraperException("Failed to load URL: '$webURL'");

    List<Map<String, dynamic>> data = [];

    bool contain = selector.contains('noscript');

    if (contain) {
      List<String> arr = selector.split('noscript');
      String benos = "${arr.first} noscript";
      selector = arr.last;

      String content = scraper.getElementTitle(benos).toString();

      bool issuccess = scraper.loadFromString(content);

      if (!issuccess)
        throw Scraper("Failed to load content from noscript element");
    }

    data = scraper.getElement(selector, attributes);

    await Future.delayed(Duration(seconds: 5));

    return data;
  }

  List<String> getAttribute(List<Map<String, dynamic>> results, String attr) {
    List<String> links = [];

    for (var data in results) {
      links.add(data['attributes'][attr] ?? '');
    }

    return links;
  }

  List<String> syncSelect(String selected, List<String> chapters) {
    List<String> selectedChp = [];

    if (selected.toLowerCase() != 'all') {
      List<String> selectedChpIndex = selected.split(',');

      for (String index in selectedChpIndex) {
        try {
          int? i = int.tryParse(index);

          if (i == null) continue;

          selectedChp.add(chapters[i]);
        } on RangeError catch (_) {
          throw new ScraperException(
              "Cannot find any chapter with index: $index");
        }
      }
    } else {
      selectedChp = chapters;
    }

    if (selectedChp.isEmpty)
      throw ScraperException("Selected chapter's is empty!");

    return selectedChp;
  }

  Future<List<Uint8List>> getNetworkFile(String url,
      [Function(String)? onProgress]) async {
    try {
      BaseOptions baseOptions = BaseOptions(
        connectTimeout: Duration(minutes: 10).inMilliseconds,
        receiveTimeout: Duration(minutes: 7).inMilliseconds,
      );

      Dio dio = new Dio(baseOptions);

      Options opt = Options(
        method: 'GET',
        responseType: ResponseType.stream,
      );

      Response<ResponseBody> rs =
          await dio.get<ResponseBody>(url, options: opt);

      ResponseBody? rb = rs.data;

      if (rb == null) throw ScraperException("Failed to get data from $url");

      List<Uint8List> bytes = [];

      int flen = int.tryParse(rb.headers['content-length']?[0] ?? '0')!;

      int received = 0;

      // var bar = ProgressBar(' [:bar] :percent :etas ', total: flen, width: 40);

      await for (Uint8List byte in rb.stream) {
        received += byte.length;

        double percentage = ((received / flen) * 100);

        // bar.tick(len: byte.length);

        bytes.add(byte);

        onProgress?.call(percentage.toStringAsFixed(3));
      }

      return bytes;
    } catch (e) {
      throw ScraperError(e.toString());
    }
  }

  Future<List<String>> downloadMultilple(
    List<String> urls,
    String dest, {
    bool isDownloadable = true,
    Function(String)? onDonwload,
    Function(bool)? onDownloadCompleted,
  }) async {
    List<List<String>> chunks = chunckUrls(urls);

    List<String> imagesName = [];

    for (List<String> chunk in chunks) {
      // ...

      bool isChunkCompleted = false;
      int downloadCount = 0;

      bool isOneChunk = chunk.length == 1 ? true : false;

      // wait until each urls in chunk downloaded
      while (isChunkCompleted == false) {
        if (chunk.isEmpty) await Future.delayed(Duration(seconds: 5));

        // loop through chunk
        for (String url in chunk) {
          String filename = lastURL(url);

          imagesName.add(filename);

          if (isDownloadable == false) continue;

          "Downloading file: $filename".println(Styles.YELLOW);

          downloadFile(url, dest + Platform.pathSeparator + filename)
              .then((value) {
            "File '$value' downloaded successfuly".println(Styles.GREEN);
            downloadCount++;

            if (isOneChunk == true && downloadCount == 1) {
              isChunkCompleted = true;
            }

            if (downloadCount == 2) {
              isChunkCompleted = true;
            }
          });
        }

        chunk = [];
      }

      // ...
    }

    return imagesName;
  }

  List<List<String>> chunckUrls(List<String> urls, [int chunkSize = 2]) {
    List<List<String>> chunks = [];
    for (var i = 0; i < urls.length; i += chunkSize) {
      chunks.add(urls.sublist(
          i, i + chunkSize > urls.length ? urls.length : i + chunkSize));
    }
    return chunks;
  }

  Future<String> downloadFile(
    String url,
    String dest, {
    Function(String)? onDonwload,
    Function(bool)? onDownloadCompleted,
  }) async {
    try {
      List<Uint8List> bytes = await getNetworkFile(url, onDonwload);

      bool result = await saveFile(dest, bytes);

      onDownloadCompleted?.call(result);

      return lastURL(url);
    } on ThrowableX {
      rethrow;
    } catch (e) {
      throw ScraperError(e.toString());
    }
  }

  Future<bool> saveFile(String dest, List<Uint8List> bytesUi8L) async {
    File file = File(dest);

    List<int> bytes = bytesUi8L.convertToBytes();

    bytes = compressImage(bytes);

    bool isFileExists = await file.exists();

    if (!isFileExists) file = await file.create(recursive: true);

    file = await file.writeAsBytes(bytes);

    return true;
  }

  List<int> compressImage(List<int> bytes) {
    Image? image = decodeImage(bytes);

    if (image == null) throw ImageException("Failed to encode image");

    return encodeJpg(image, quality: 65);
  }

  Future<bool> saveFileAsString(String dest, String content) async {
    File file = File(dest);

    bool isFileExists = await file.exists();

    if (!isFileExists) file = await file.create(recursive: true);

    file = await file.writeAsString(content);

    return true;
  }

  Future<void> iterateMap({
    required List<Map<String, dynamic>> listMap,
    required Future<void> Function(String, dynamic) onLoop,
  }) async {
    for (Map<String, dynamic> chap in listMap) {
      for (MapEntry<String, dynamic> map in chap.entries) {
        await onLoop.call(map.key, map.value);
      }
    }
  }
}
