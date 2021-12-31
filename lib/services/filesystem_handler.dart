// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:cli/bootstrap.dart';

class FSHandler {
  // ...

  final String sp = Platform.pathSeparator;

  Future<void> genDataDirectory() async {
    String root_dir = App.fd_name;

    Directory directory = Directory(root_dir);

    await for (FileSystemEntity fs_web in directory.list()) {
      // genning webs directory
      await genWebDirectory(fs_web);
    }
  }

  Future<void> genWebDirectory(FileSystemEntity fs_web) async {
    Directory directory = Directory(fs_web.path);

    List<String> comicPath = [];

    await for (FileSystemEntity fs_comic in directory.list()) {
      // genning comics directory
      String? cpath = await genComicDirectory(fs_comic);

      if (cpath == null) continue;

      comicPath.add(cpath);
    }

    String vendor = getLastFolder(directory);

    DocumentHandler document = DocumentHandler(PageType.comic);

    await document.loadTemplate();

    document.assignData(
      documentTitle: "$vendor | WGCLI",
      headerText: vendor,
      footerText: 'WGCLI',
      items: comicPath,
    );

    document.storeDocument("${directory.path}$sp$vendor.html");
  }

  Future<String?> genComicDirectory(FileSystemEntity fs_comic) async {
    if (fs_comic is File) return null;

    String vendor = getLastFolder(fs_comic.parent);

    Directory comic_dir = Directory(fs_comic.path);

    String comic_name = getLastFolder(comic_dir);

    List<String> chapters_path = [];

    // gen comic directory
    await for (FileSystemEntity fs_chap in comic_dir.list()) {
      // on gening comic
      String? chapter =
          await genChapterDirectory(fs_chap: fs_chap, vendor: vendor);

      if (chapter == null) continue;

      chapters_path.add(chapter);
    }

    // sort chapters
    chapters_path.sort((String a, String b) {
      int chin_a = int.tryParse(a.split('-').last) ?? 0;
      int chin_b = int.tryParse(b.split('-').last) ?? 1;

      return chin_a.compareTo(chin_b);
    });

    DocumentHandler document = DocumentHandler(PageType.chapter);

    await document.loadTemplate();

    document.assignData(
      documentTitle: "$comic_name | $vendor",
      headerText: comic_name,
      footerText: vendor,
      items: chapters_path,
    );

    String docPath = "${comic_dir.path}$sp$comic_name.html";

    await document.storeDocument(docPath);

    return "$comic_name$sp$comic_name.html";
  }

  Future<String?> genChapterDirectory({
    required FileSystemEntity fs_chap,
    required String vendor,
  }) async {
    if (fs_chap is File) return null;

    String comic_name = getLastFolder(fs_chap.parent);

    String chap_path = fs_chap.path;

    File file = File("$chap_path${sp}images.json");

    if (!await file.exists()) return null;

    var json = await file.readAsString();

    List<dynamic> chaps = jsonDecode(json);

    String chapter_index = getLastFolder(fs_chap);

    String chapter_name = chapter_index.replaceAll(comic_name.trim(), '');

    DocumentHandler document = DocumentHandler(PageType.read);

    await document.loadTemplate();

    document.assignData(
      documentTitle: "$chapter_name | $comic_name",
      headerText: chapter_name,
      footerText: comic_name,
      items: chaps.cast<String>(),
    );

    String store_path = "$chap_path$sp$chapter_index.html";

    await document.storeDocument(store_path);

    return chapter_index;
  }

  Future<File> saveDocument(String path, String content) async {
    File file = File(path);

    if (!await file.exists()) await file.create(recursive: true);

    file = await file.writeAsString(content);

    return file;
  }

  String getLastFolder(FileSystemEntity directory) {
    return directory.path.split(sp).last;
  }
}
