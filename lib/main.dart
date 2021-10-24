import 'package:flutter/material.dart';
import 'package:mi_watchface_app/screens/home_screen.dart';
import 'package:mi_watchface_app/theme/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: MyTheme.lightTheme(),
      darkTheme: MyTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
