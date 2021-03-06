// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names

import 'package:cli/bootstrap.dart';

Future<bool> runtime_cli() async {
  try {
    // ...

    _logSupportedWebs();

    await _scrapeTask();

    return askExit();

    // ...
  } on ValidationError catch (throwable) {
    log(
      'Validation Error Has been Thrown',
      throwable,
      logStack: LogStack.warning,
      extendDivider: 20,
    );
    return askExit();
  } on ThrowableX catch (throwable) {
    log(
      'An Exception Has Occured',
      throwable,
      logStack: LogStack.error,
      extendDivider: 20,
    );
    return askExit();
  } on ThrowableE catch (throwable) {
    log(
      'An Error Has Occured',
      throwable,
      logStack: LogStack.error,
      extendDivider: 30,
    );
  }

  return false;
}

void banner() {
  List<String> banner = [
    'Welcome To ComicScraper',
    'A Powerfull CLI For Scraping Webcomic From Paticular Websites',
    '- By -',
    '@cloudmyn(https://github.com/CloudMyn)',
    'Sunday, December 26-2021',
  ];

  _log(banner, char: '=');
}

void _help() {
  List<String> helps = [
    'webs\t: show supported websites',
    'webg\t: r/generate data directory ',
  ];

  _log(
    ["List of commands available"],
    char: "#",
    dividerExtend: 10,
    center: false,
  );
}

void _log(
  List<String> texts, {
  bool center = true,
  String char = '-',
  int dividerExtend = 10,
}) {
  String prevstr = '';

  String choosed = '';

  for (String str in texts) {
    // get the longest string in the list
    if (str.length > prevstr.length && str.length > choosed.length) {
      choosed = str.trim();
    }

    prevstr = str.trim();
  }

  String text = texts.join('\n\n');

  if (center)
    text = centerAligment(texts, choosed.length, dividerExtend).join('\n\n');

  String divider = (char * (choosed.length + dividerExtend)) + "\n";

  text = ((divider + '\n') + (text + "\n\n") + divider);

  "".println();

  logc(text, LogStack.banner, true);
}

void _logSupportedWebs() {
  List<String> websites = _getWebsites();

  _log([
    ' Supported Website',
    for (var web in websites) "  $web",
  ], center: false, char: '#');
}

Future<void> _scrapeTask() async {
  List<String> websites = _getWebsites();

  String resp1 = ask(
    "select website: ",
    require: true,
    defaultValue: '808',
  )!
      .toString();

  int webIndex = int.tryParse(resp1) ?? 909;

  if (webIndex == 808)
    throw ValidationError("Please select one of those websites.");

  if (webIndex == 909)
    throw InputException("Invalid character detected, Only accepted number");

  if (webIndex > _getWebsites().length - 1)
    throw InputException("No websites with index: [$webIndex]");

  _log([
    "Website with index [$webIndex] selected",
    websites[webIndex],
  ], char: '#');

  String url = ask("Enter URL : ", require: true)!.toString();

  String pattern = r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+';

  if (!RegExp(pattern).hasMatch(url)) throw ValidationError('invalid URL');

  late ComicScraper web;

  switch (webIndex) {
    case 0:
      web = KiryuuId(comic: url);
      break;
    case 1:
      web = AsuraScans(comic: url);
      break;
    case 2:
      web = LuminousScans(comic: url);
      break;
    default:
  }

  Worker worker = Worker.assign(web);

  await worker.runTask((ComicScraper web) async {
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

    List<String> selectedChapters = await selectChapters(web);

    if (selectedChapters.isEmpty) return false;

    var rsp2 = ask(
      'Would you like to download the images and store it? (Y/N)[Y] : ',
      require: true,
      defaultValue: 'Y',
    )!
        .toString()
        .toLowerCase();

    "".println();

    bool isDOwnloadable = rsp2 != 'y' ? false : true;

    await web.getChapterImages(selectedChapters);

    String selectedListLog = await logListting(web.chaptersImages);

    log(
      "** Selected chapters **",
      selectedListLog,
      logStack: LogStack.info,
      extendDivider: 15,
    );

    "Done: Getting images on each selected chapters completed.\n"
        .println(Styles.GREEN);

    await web.saveChapters(isDOwnloadable);

    _log(["Scraping completed successfuly."]);

    return true;

    // ...
  });
}

List<String> _getWebsites() {
  return [
    '[0]  https://www.kiryuu.id/',
    '[1]  https://www.asurascans.com/',
    '[2]  https://luminousscans.com/'
  ];
}

Future<List<String>> selectChapters(ComicScraper web) async {
  List<String> chapters = web.chapters;

  String response = ask(
    "Choose chapters you want to save: ",
    require: true,
    defaultValue: '',
  ).toString().toLowerCase();

  "\nStart: Getting images on each selected chapters...".println(Styles.YELLOW);

  if (chapters.isEmpty)
    throw ScraperException("There is no chapters available!");

  List<String> selectedChp = [];

  // perintah 'all' akan memilih semua chapter yang tersedia
  if (response == 'all') {
    selectedChp.addAll(web.chapters);
  }

  // perintah 'except' akan memilih semua chapter kecuali yang di masukkan
  else if (response.contains('all-x:')) {
    String xchp = response.split(":").last;

    for (int i = 0; i < chapters.length; i++) {
      bool exception = xchp.contains(i.toString());

      if (exception) continue;

      selectedChp.add(chapters[i]);
    }
  }

  // jika terdapat karakter '..' sebelum dan setelahnya nomor
  // maka perintah tersebut adalah 'range'
  else if (response.contains('..')) {
    int? min = int.tryParse(response.split('..').first);
    int? max = int.tryParse(response.split('..').last);

    if (min == null || max == null)
      throw RuntimeException("Invalid range command");

    if (min >= max)
      throw RuntimeException('First index must greater than Last index');

    if (max == 0) throw RuntimeException("Max range cannot be 0");

    if (max > chapters.length) throw RuntimeException('Max range overflow');

    for (int i = 0; i < chapters.length; i++) {
      if (i >= min && i <= max) selectedChp.add(chapters[i]);
    }
  }

  // if response contains only comma and numbers
  else if (response.contains(',')) {
    for (int i = 0; i < chapters.length; i++) {
      bool isSelected = response.contains(i.toString());

      if (!isSelected) continue;

      selectedChp.add(chapters[i]);
    }
  }

  // if response is integer
  else if (int.tryParse(response) != null) {
    selectedChp.add(chapters[int.parse(response)]);
  }

  return selectedChp;
}
