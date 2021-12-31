// @Timeout(Duration(minutes: 3))

// ignore_for_file: non_constant_identifier_names

import 'package:cli/bootstrap.dart';
import 'package:test/test.dart';

void main() {
  test('Kiryuu test scraping', () async {
    const testURL = 'https://kiryuu.id/manga/the-villain-of-destiny/';

    ComicScraper web = KiryuuId(comic: testURL);

    bool result = await full_scraping_test(web);

    expect(result, true);

    // ...
  });
  test('AsuraScans test scraping', () async {
    const testURL =
        "https://www.asurascans.com/comics/20-reformation-of-the-deadbeat-noble/";

    ComicScraper web = AsuraScans(comic: testURL);

    bool result = await full_scraping_test(web);

    expect(result, true);

    // ...
  });
}

Future<bool> full_scraping_test(ComicScraper web) async {
  Worker worker = Worker.assign(web);

  return await worker.runTask((ComicScraper web) async {
    // ...

    "Start\t: Get comic chapters".println();

    await web.getChapters();

    "Done\t: Get comic chapters".println();

    String chaptersListLog = await logListting(web.chapters);

    log(
      "List chapters of the comic ${web.comicName()}",
      chaptersListLog,
      logStack: LogStack.info,
      extendDivider: 8,
    );

    String selected = '0';

    "Start\t: Get chapters images".println();

    await web.getChapterImages(selected);

    "Done\t: Get chapters images".println();

    String selectedListLog = await logListting(web.chaptersImages);

    log(
      "## Selected chapters! ##",
      selectedListLog,
      logStack: LogStack.info,
      extendDivider: 30,
    );

    await web.saveChapters(true);

    return true;

    // ...
  });
}
