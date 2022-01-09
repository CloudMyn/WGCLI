// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:cli/bootstrap.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

enum PageType { web, comic, chapter, read }

class DocumentHandler {
  final PageType pageType;
  Document? dom;

  DocumentHandler(this.pageType);

  Future<Document> loadTemplate() async {
    try {
      String templatePath = getTmpPath();

      File template = File(templatePath);

      if (await template.exists() == false)
        throw DocumentError("Web template not found in directory './rawpage'");

      return dom = parse(await template.readAsString());
    } on FileSystemException catch (e) {
      throw DocumentException(e.toString());
    }
  }

  void assignData({
    required String documentTitle,
    required String headerText,
    required String footerText,
    required List<String> items,
  }) {
    if (dom == null)
      throw DocumentException('DOM is null, please load the template first!');

    Element titleEl = querySelector('title');

    titleEl.innerHtml = documentTitle.replaceAll("-", " ");

    Element headerBoxEl = querySelector('#wraper .box .box-header .title');

    headerBoxEl.innerHtml = headerText.replaceAll("-", " ");

    Element footerBoxEL =
        querySelector('#wraper .box .box-footer .action button');

    footerBoxEL.innerHtml = footerText.replaceAll("-", " ");

    switch (pageType) {
      case PageType.web:
        _assignWebPageData(items);
        break;
      case PageType.comic:
        _assignComicPageData(items);
        break;
      case PageType.chapter:
        _assignChapterPageData(items);
        break;
      case PageType.read:
        _assignReadPageData(items);
        break;
    }
  }

  void _assignWebPageData(List<String> items) {
    Element? boxComic = dom!.querySelector("#wraper .box .box-chapters");

    if (boxComic == null)
      throw DocumentException("Cannot find .box-chapters element!");

    boxComic.innerHtml = "";

    DateTime dt = DateTime.now();

    for (String comic in items) {
      Element anchor = dom!.createElement('a');

      anchor.attributes.addAll({'href': "$comic/index.html"});

      anchor.classes.add('chapter-link');

      String date = "${dt.year}";

      String vendor = comic.split('\\').last.replaceAll('-', ' ');

      anchor.innerHtml = "<span>$vendor</span> <span>$date</span>";

      boxComic.append(anchor);
    }
  }

  void _assignComicPageData(List<String> items) {
    Element? boxComic = dom!.querySelector("#wraper .box .box-chapters");

    if (boxComic == null)
      throw DocumentException("Cannot find .box-chapters element!");

    boxComic.innerHtml = "";

    DateTime dt = DateTime.now();

    for (String comic in items) {
      Element anchor = dom!.createElement('a');

      anchor.attributes.addAll({'href': "$comic/index.html"});

      anchor.classes.add('chapter-link');

      String date = "${dt.year}";

      String comic_name = comic.split('\\').last.replaceAll('-', ' ');

      comic_name = comic_name.replaceAll('.html', '');

      anchor.innerHtml = "<span>$comic_name</span> <span>$date</span>";

      boxComic.append(anchor);
    }
  }

  void _assignChapterPageData(List<String> items) {
    Element? boxChapter = dom!.querySelector("#wraper .box .box-chapters");

    if (boxChapter == null)
      throw DocumentException("Cannot find .box-chapters element!");

    boxChapter.innerHtml = "";

    DateTime dt = DateTime.now();

    for (String chapter in items) {
      Element anchor = dom!.createElement('a');

      anchor.attributes.addAll({'href': "$chapter/$chapter.html"});

      anchor.classes.add('chapter-link');

      String date = "gen-at: ${dt.day}-${dt.month}:${dt.year}";

      anchor.innerHtml = "<span>$chapter</span> <span>$date</span>";

      boxChapter.append(anchor);
    }
  }

  void _assignReadPageData(List<String> items) {
    Element? readerArea = dom!.querySelector("#wraper .box .reader-area");

    if (readerArea == null)
      throw DocumentException(
          "Cannot find any element with selector: '.reader-area'");

    readerArea.innerHtml = "";

    for (String image in items) {
      Element img = dom!.createElement('img');

      bool isURL = Uri.tryParse(image)?.hasAbsolutePath ?? false;

      Map<Object, String> attributes = {
        'alt': lastURL(image),
      };

      if (isURL) {
        attributes['lazy-src'] = image;
        attributes['style'] = 'display: none';
      } else {
        attributes['src'] = image;
      }

      img.attributes.addAll(attributes);

      readerArea.append(img);
    }
  }

  Future<void> storeDocument(String path) async {
    File document = File(path);

    if (!await document.exists()) await document.create(recursive: true);

    if (dom == null) throw DocumentException("DOM is empty");

    // if (dom!.text == null)
    //   throw DocumentException("HTML page content cannot be null!");

    document.writeAsString(dom!.outerHtml);
  }

  Element querySelector(String selector) {
    Element? el = dom!.querySelector(selector);

    if (el == null)
      throw DocumentException(
          "Cannot find any element with selector: '$selector' ");

    return el;
  }

  String getTmpPath() {
    String route = '';
    switch (pageType) {
      case PageType.web:
        route = App.rawpage_directory('webs.page.html');
        break;
      case PageType.comic:
        route = App.rawpage_directory('comics.page.html');
        break;
      case PageType.chapter:
        route = App.rawpage_directory('chapters.page.html');
        break;
      case PageType.read:
        route = App.rawpage_directory('read.page.html');
        break;
    }
    return route;
  }
}
