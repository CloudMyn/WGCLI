// @Timeout(Duration(minutes: 3))

// ignore_for_file: non_constant_identifier_names

import 'package:cli/bootstrap.dart';
import 'package:test/test.dart';

void main() {
  test('Kiryuu id test', () async {
    const testURL = 'https://kiryuu.id/manga/the-villain-of-destiny/';

    ComicScraper web = KiryuuId(comic: testURL);

    bool result = await full_scraping_test(web);

    expect(result, true);

    // ...
  });
  test('Asura scans test', () async {
    const testURL =
        "https://www.asurascans.com/comics/20-reformation-of-the-deadbeat-noble/";

    ComicScraper web = AsuraScans(comic: testURL);

    bool result = await full_scraping_test(web);

    expect(result, true);

    // ...
  });

  test('Luminous scans test', () async {
    const testURL =
        "https://www.asurascans.com/comics/20-reformation-of-the-deadbeat-noble/";

    ComicScraper web = LuminousScans(comic: testURL);

    bool result = await full_scraping_test(web);

    expect(result, true);

    // ...
  });
}

Future<bool> full_scraping_test(ComicScraper web) async {
  Worker worker = Worker.assign(web);

  return await worker.runTask((ComicScraper web) async {
    // ...

    "\nStart: Getting comic chapters...".println(Styles.YELLOW);

    await web.getChapters();

    String chaptersListLog = await logListting(web.chapters);

    log(
      "List chapters of the comic ${web.comicName()}",
      chaptersListLog,
      logStack: LogStack.info,
      extendDivider: 8,
    );

    "Done: Getting comic chapter completed.\n".println(Styles.GREEN);

    String selected = ask(
      "Choose chapters you want to save: ",
      require: true,
      defaultValue: '',
    ).toString();

    "\nStart: Getting images on each selected chapters..."
        .println(Styles.YELLOW);

    bool result = await web.getChapterImages(selected);

    if (result == false) return false;

    String selectedListLog = await logListting(web.chaptersImages);

    log(
      "** Selected chapters **",
      selectedListLog,
      logStack: LogStack.info,
      extendDivider: 15,
    );

    "Done: Getting images on each selected chapters completed.\n"
        .println(Styles.GREEN);

    var rsp2 = ask(
      'Would you like to download the images and store it? (Y/N)[Y] : ',
      require: true,
      defaultValue: 'Y',
    )!
        .toString()
        .toLowerCase();

    "".println();

    bool isDOwnloadable = rsp2 != 'y' ? false : true;

    await web.saveChapters(isDOwnloadable);

    return true;

    // ...
  });
}
