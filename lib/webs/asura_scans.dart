// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, unnecessary_this

import 'dart:async';

import 'package:cli/bootstrap.dart';

class AsuraScans extends Scraper implements ComicScraper {
  @override
  String origin = "https://www.asurascans.com/";

  @override
  String vendor = 'AsuraScans';

  @override
  String comic;

  @override
  List<String> chapters = [];

  @override
  List<Map<String, dynamic>> chaptersImages = [];

  @override
  List<String> selectedChapters = [];

  AsuraScans({required this.comic, this.chapters = const []}) : super();

  @override
  Future<void> getChapters() async {
    var results = await super.scrapeWeb(
      webURL: comic,
      selector: selector_chp,
      attributes: ['href'],
    );

    chapters = super.getAttribute(results, 'href');
    chapters = chapters.reversed.toList();
  }

  @override
  Future<bool> getChapterImages(List<String> selectedChp) async {
    List<String> attributes = ['src', 'lazy'];

    for (String chap in selectedChp) {
      var results = await super.scrapeWeb(
        webURL: chap,
        selector: selector_img,
        attributes: attributes,
      );

      var images = super.getAttribute(results, 'src');

      chaptersImages.add({
        chap: images,
      });
    }

    if (chaptersImages.isEmpty) return false;

    return true;
  }

  @override
  Future<bool> saveChapters(bool isDOwnloadable) async {
    if (chaptersImages.isEmpty) return false;

    await this.iterateMap(
      listMap: chaptersImages,
      onLoop: (key, value) async {
        String chap = lastURL(key);
        List<String> images = value as List<String>;

        "Downloading chapter $chap".println(Styles.LIGHT_YELLOW);

        List<String> imagesName = await super.downloadMultilple(
          images,
          ComicScraper.getStorePath(this, chap, ""),
        );

        "Download completed".println(Styles.LIGHT_GREEN);

        await ComicScraper.saveJson(this, chap, imagesName);
      },
    );

    return true;
  }

  @override
  String comicName() {
    return comic.replaceAll('/', ' ').trim().split(' ').last;
  }

  @override
  String get selector_cmc => "";

  @override
  String get selector_chp => "#chapterlist div.eph-num a";

  @override
  String get selector_img => '#readerarea p img';
}
