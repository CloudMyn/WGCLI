// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, unnecessary_this

import 'package:cli/bootstrap.dart';

class LuminousScans extends Scraper implements ComicScraper {
  @override
  String origin = "https://luminousscans.com/";

  @override
  String vendor = 'LuminousScans';

  @override
  String comic = "";

  @override
  List<String> chapters = [];

  @override
  List<Map<String, dynamic>> chaptersImages = [];

  @override
  List<String> selectedChapters = [];

  LuminousScans({required this.comic, this.chapters = const []}) : super();

  @override
  String comicName() {
    return lastURL(comic);
  }

  @override
  Future<bool> getChapterImages(List<String> selectedChp) async {

    // List<String> selectedChp = super.syncSelect(selected, chapters);

    List<String> attributes = ['src'];

    for (String chap in selectedChp) {
      var results = await super.scrapeWeb(
        webURL: chap,
        attributes: attributes,
        selector: selector_img,
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
  Future<bool> saveChapters(bool isDOwnloadable) async {
    if (chaptersImages.isEmpty) return false;

    await this.iterateMap(
      listMap: chaptersImages,
      onLoop: (key, value) async {
        String chap = lastURL(key);
        List<String> images = value as List<String>;

        "Downloading chapter $chap".println(Styles.LIGHT_YELLOW);

        List<String> imagesName = await super.downloadMultilple(
            images, ComicScraper.getStorePath(this, chap, ""));

        "Download completed".println(Styles.LIGHT_GREEN);

        await ComicScraper.saveJson(this, chap, imagesName);
      },
    );

    return true;
  }

  @override
  String get selector_cmc => '#content div.wrapper div.postbody div.luf a';

  @override
  String get selector_chp => '#chapterlist ul li div a';

  @override
  String get selector_img => '#readerarea p img';
}
