import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gradient_mouse/ui/home_screen.dart';
import 'package:gradient_mouse/theme/custom_dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final program = await ui.FragmentProgram.fromAsset(
    'shaders/gradient_blinds.frag',
  );
  final shader = program.fragmentShader();

  runApp(MyApp(shader: shader));
}  

class MyApp extends StatelessWidget {
  final ui.FragmentShader shader;
  const MyApp({Key? key, required this.shader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: WebTheme.darkWebTheme,
      home: HomeScreen(shader: shader), // Separate widget
    );
  }
}