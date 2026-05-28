import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gradient_mouse/ui/home_screen.dart';
import 'package:gradient_mouse/theme/custom_dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ui.FragmentShader? shader;

  try {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/gradient_blinds.frag',
    );
    shader = program.fragmentShader();
  } catch (e) {
    debugPrint('Shader failed to load: $e');
  }

  runApp(MyApp(shader: shader));
}

class MyApp extends StatelessWidget {
  final ui.FragmentShader? shader;           // ← nullable
  const MyApp({Key? key, required this.shader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: WebTheme.darkWebTheme,
      home: shader != null
          ? HomeScreen(shader: shader!)
          : const _ShaderErrorScreen(),      // ← fallback
    );
  }
}

// Simple fallback so the app doesn't crash
class _ShaderErrorScreen extends StatelessWidget {
  const _ShaderErrorScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Loading...', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}