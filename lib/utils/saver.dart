import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_archive/flutter_archive.dart';
// import 'package:flutter_archive/flutter_archive.dart';

class MyDownloader {
  //firestore instance
  static final _firestore = FirebaseFirestore.instance;

  //dio instance
  static final dio = Dio();

  //downloading zip link from firestore
  static Future<void> dnldfiles(String basepath, {int folderno = 77}) async {
    var links = await _firestore
        .collection('files')
        .doc(folderno.toString())
        .get()
        .then((value) {
      return value.data();
    });

    //zip name
    String zipname = basepath + "/testing.zip";

    // //image name
    // String imagename = basepath + "/$folderno.png";

    // //gif name
    // String gifname = basepath + "/$folderno.gif";

    // //infos.xml file name
    // String infosname = basepath + "/infos.xml";

    // dio.download(links!["image"], imagename);
    // dio.download(links["gif"], gifname);
    // dio.download(links["infos"], infosname);

    await dio.download(links!["zip"], zipname);

    //Downloading zip file
    final zipFile = File(zipname);
    final destinationDir = Directory(basepath);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: destinationDir);
    } catch (e) {
      print(e);
    }

    //deleting downloaded zip after extracting
    try {
      File(zipname).delete();
    } catch (e) {
      print(e);
    }
  }
}
