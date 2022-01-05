// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cli/bootstrap.dart';

abstract class ComicScraper extends Scraper {
  abstract String origin;

  abstract String vendor;

  abstract String comic;

  abstract List<String> chapters;

  abstract List<String> selectedChapters;

  abstract List<Map<String, dynamic>> chaptersImages;

  abstract final String selector_cmc;

  abstract final String selector_chp;

  abstract final String selector_img;

  String comicName();

  Future<void> getChapters();

  Future<bool> getChapterImages(List<String> selected);

  Future<bool> saveChapters(bool isDownloadable);

  static String getStorePath(ComicScraper cmc, String chap, String filename) {
    String comic = cmc.comicName();
    String sp = Platform.pathSeparator;
    return "./data/${cmc.vendor}/$comic/$chap/$filename".replaceAll('/', sp);
  }

  static Future<void> saveJson(ComicScraper web, String chap, List<String> chapters) async {
    String spath = ComicScraper.getStorePath(web, chap, "images.json");
    await web.saveFileAsString(spath, jsonEncode(chapters));
  }
}
