import 'package:flutter/material.dart';
import 'package:kd_translater/translate_speak_demo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TranslateSpeakDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}
