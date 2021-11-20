import 'dart:io';

import 'package:flutter_application_1/utils/saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHandler {
  static createFile() async {
    if ((await Permission.storage.request().isGranted)) {
      Directory? testdir = await getExternalStorageDirectory();
      var stringpath = testdir!.parent.parent.path;

      stringpath += "/com.xiaomi.hm.health/files/watch_skin_local";

      // var f = await File(
      //         "$stringpath/com.xiaomi.hm.health/files/watch_skin_local/77/hello.txt")
      //     .create(recursive: true);
      // f.writeAsString("hi my name is krishnaveer singh");

      MyDownloader.dnldfiles(stringpath);

      print(
          "..........$stringpath...........flie created.......................");
    } else {
      await Permission.storage.request();
      // await openAppSettings();
    }
  }
}
