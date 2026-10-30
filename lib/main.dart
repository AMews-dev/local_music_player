import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/start.dart';
import 'package:flutter_application_1/services/music_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await MusicController().initPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
    ); // MaterialApp
  }
}