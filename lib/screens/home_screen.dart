import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_watchface_app/utils/nav_dir.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _watchFaces = [];
  bool isLoadingFaces = true;
  int _per_page = 15;
  late DocumentSnapshot _lastWatchFace;
  final ScrollController _scrollController = ScrollController();
  bool _gettingMoreWatchFaces = false;
  bool _moreWatchFacesAvailable = true;

  //variables to support download progress tracker
  bool downloading = false;
  String progress = '0'; //progress percentage
  bool isDownloaded = false;

  var bs = ButtonState.idle; //variable using for setting progress button state

// --------------------------------------------------------------------------------------------

  // downloading logic is handled by this method
  Future<void> downloadFile(uri) async {
    setState(() {
      downloading = true;
      bs = ButtonState.loading;
    });

    String basePath = await MyHandler.createFile();

    //setting zip file name
    String savePath = basePath + "/${uri.hashCode}.zip";

    Dio dio = Dio();

    await dio.download(
      uri,
      savePath,
      onReceiveProgress: (rcv, total) {
        print(
            'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

        setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
        });

        if (progress == '100') {
          setState(() {
            isDownloaded = true;
            bs = ButtonState.success;
          });
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      setState(() {
        if (progress == '100') {
          isDownloaded = true;
          bs = ButtonState.success;
        }

        downloading = false;
      });
    });

    //extracting zip file
    final zipFile = File(savePath);

    //TODO:remove   + "/5"  after zipped all files in folder
    final destinationDir = Directory(basePath + "/5");
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: destinationDir);
    } catch (e) {
      print(e);
    }

    // deleting downloaded zip after extracting
    try {
      File(savePath).delete();
    } catch (e) {
      print(e);
    }
  }

  // -------------------------------------------------------------------------------------------------

  _getWatchFaces() async {
    Query q = _firestore
        .collection("home watch faces list")
        .orderBy("date", descending: true)
        .limit(_per_page);
    setState(() {
      isLoadingFaces = true;
    });
    QuerySnapshot querySnapshot = await q.get();
    _watchFaces = querySnapshot.docs;
    _lastWatchFace = querySnapshot.docs[querySnapshot.docs.length - 1];
    setState(() {
      isLoadingFaces = false;
    });
  }

  _getMoreWatchFaces() async {
    print("_getMoreWatchFaces Called");
    if (_moreWatchFacesAvailable == false) {
      print("No more products");
      return;
    }
    if (_gettingMoreWatchFaces == true) {
      return;
    }
    _gettingMoreWatchFaces = true;
    Query q = _firestore
        .collection("home watch faces list")
        .orderBy("date", descending: true)
        .startAfterDocument(_lastWatchFace)
        .limit(_per_page);

    QuerySnapshot querySnapshot = await q.get();
    if (querySnapshot.docs.length < _per_page) {
      _moreWatchFacesAvailable = false;
    }
    _lastWatchFace = querySnapshot.docs[querySnapshot.docs.length - 1];
    _watchFaces.addAll(querySnapshot.docs);

    setState(() {});
    _gettingMoreWatchFaces = false;
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    _getWatchFaces();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll <= delta) {
        _getMoreWatchFaces();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.cardColor,
        body: SafeArea(
          child: isLoadingFaces == true
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green))
              : Container(
                  padding: Vx.mOnly(top: 4, left: 4, right: 4, bottom: 4),
                  child: _watchFaces.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: GridView.builder(
                          controller: _scrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 60 / 55, crossAxisCount: 1),
                          shrinkWrap: true,
                          itemCount: _watchFaces.length,
                          itemBuilder: (context, index) {
                            return VxBox(
                                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14)),
                                  child: Container(
                                    width: double.infinity,
                                    height: 40,
                                    color: Colors.blueGrey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                              "Author :  ${_watchFaces[index].get("author")}",
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          const VerticalDivider(
                                            thickness: 1,
                                            endIndent: 3,
                                            indent: 2,
                                            color: Colors.white,
                                          ),
                                          const Icon(
                                            CupertinoIcons.cloud_download,
                                            size: 18,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text("1000",
                                                style: TextStyle(fontSize: 16)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Image.asset(
                                              "assets/files/frame1.png",
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 24,
                                                      horizontal: 35),
                                              child: Container(
                                                height: 190,
                                                width: 65,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          _watchFaces[index]
                                                              .get("GifLink")),
                                                      fit: BoxFit.fill,
                                                    ),
                                                    color: Colors.black,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                36))),
                                              )),
                                        ],
                                      ),
                                      // const VerticalDivider(
                                      //     endIndent: 22,
                                      //     indent: 22,
                                      //     color: Colors.grey),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            VxBox(
                                                    child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .horizontal(
                                                          left: Radius.circular(
                                                              14)),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    color: context.cardColor,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text("Language",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _watchFaces[index]
                                                        .get("Language"),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                )
                                              ],
                                            ))
                                                .width(MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.499)
                                                .margin(
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10))
                                                .customRounded(
                                                    const BorderRadius.all(
                                                        Radius.circular(12)))
                                                .color(context.canvasColor)
                                                .make(),
                                            VxBox(
                                                    child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .horizontal(
                                                          left: Radius.circular(
                                                              14)),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    color: context.cardColor,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text("Type",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _watchFaces[index]
                                                        .get("type"),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                )
                                              ],
                                            ))
                                                .width(MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.499)
                                                .margin(
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10))
                                                .customRounded(
                                                    const BorderRadius.all(
                                                        Radius.circular(12)))
                                                .color(context.canvasColor)
                                                .make(),
                                            VxBox(
                                                    child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                              .horizontal(
                                                          left: Radius.circular(
                                                              14)),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    color: context.cardColor,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text("Time format",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _watchFaces[index]
                                                        .get("time format"),
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                )
                                              ],
                                            ))
                                                .width(MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.499)
                                                .margin(const EdgeInsets.only(
                                                    top: 10, bottom: 20))
                                                .customRounded(
                                                    const BorderRadius.all(
                                                        Radius.circular(12)))
                                                .color(context.canvasColor)
                                                .make(),
                                            Material(
                                                elevation: 5,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.blueGrey,
                                                child: ProgressButton.icon(
                                                    iconedButtons: {
                                                      ButtonState.idle:
                                                          IconedButton(
                                                              text: "Install",
                                                              icon: Icon(
                                                                  Icons.send,
                                                                  color: Colors
                                                                      .white),
                                                              color: Colors
                                                                  .deepPurple
                                                                  .shade500),
                                                      ButtonState.loading:
                                                          IconedButton(
                                                              text: "Loading",
                                                              color: Colors
                                                                  .deepPurple
                                                                  .shade700),
                                                      ButtonState.fail:
                                                          IconedButton(
                                                              text: "Failed",
                                                              icon: Icon(
                                                                  Icons.cancel,
                                                                  color: Colors
                                                                      .white),
                                                              color: Colors.red
                                                                  .shade300),
                                                      ButtonState.success:
                                                          IconedButton(
                                                              text: "Success",
                                                              icon: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              color: Colors
                                                                  .green
                                                                  .shade400)
                                                    },
                                                    onPressed: () async {
                                                      downloadFile(_watchFaces[
                                                              index]
                                                          .get("installFile"));
                                                    },
                                                    //TODO:state of button not working properly
                                                    state: bs))
                                            // Text("Type : Digital"),
                                            // Text("Time format : 24 Hours")
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ))
                                .margin(const EdgeInsets.all(8))
                                .customRounded(
                                    const BorderRadius.all(Radius.circular(14)))
                                .color(const Color.fromRGBO(57, 62, 70, 0.4))
                                .make();
                          },
                        )),
                ),
        ));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
