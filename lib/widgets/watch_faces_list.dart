import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class WatchFacesList extends StatelessWidget {
  const WatchFacesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final watchFacesItems = StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("home watch faces list")
          .limit(8)
          .orderBy("date", descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return const Text("No Data");
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/files/frame1.png",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: Container(
                          height: 200,
                          width: 63,
                          decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35))),
                          child: Image.network(snapshot.data.documents.get('GifLink')),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            "Language".text.sm.color(Colors.white70).make().p8(),
          ],
        );
      },
    );
    

    return VxBox(
      child: watchFacesItems,
    )
        .margin(const EdgeInsets.all(5))
        .customRounded(const BorderRadius.all(Radius.circular(12)))
        .color(context.canvasColor)
        .make();
  }
}
