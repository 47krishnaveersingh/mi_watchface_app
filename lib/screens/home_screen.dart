import 'package:flutter/material.dart';
import 'package:mi_watchface_app/widgets/watch_faces_list.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        title: "Mi Band 6 Watch Faces".text.make().centered(),
      ),
      body: SafeArea(
          child: Container(
        padding: Vx.mOnly(top: 4, left: 4, right: 4, bottom: 4),
        child: SingleChildScrollView(
          child: GridView.builder(
            physics: ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 60 / 100, crossAxisCount: 2),
            shrinkWrap: true,
            itemCount: 30,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {},
                child: WatchFacesList(),
              );
            },
          ),
        ),
      )),
    );
  }
}
