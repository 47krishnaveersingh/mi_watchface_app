import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class WatchFacesList extends StatelessWidget {
  const WatchFacesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final watchFacesItems = Column(
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
                          borderRadius: BorderRadius.all(Radius.circular(35))),
                      child: Image.asset(
                        "assets/files/miband6.png",
                      ).box.make(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        "Mi Band 6 Watch Faces".text.xl.color(Colors.white70).make().p8(),
      ],
    );

    return VxBox(
      child: watchFacesItems,
    )
        .margin(const EdgeInsets.all(2))
        .customRounded(const BorderRadius.all(Radius.circular(12)))
        .color(context.canvasColor)
        .make();
  }
}
