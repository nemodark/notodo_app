import 'package:flutter/material.dart';
import 'package:notodo_app/ui/home.dart';
import 'package:flutter/services.dart';

// void main() => runApp(MyApp());

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.black87
));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoToDo',
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
