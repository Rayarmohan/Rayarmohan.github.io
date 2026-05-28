import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GradientBlinds extends StatefulWidget {
  final ui.FragmentShader shader;
  final List<Color>? gradientColors;
  final bool paused;
  final double angle; // in degrees
  final double noise;
  final double blindCount;
  final double blindMinWidth;
  final double mouseDampening;
  final bool mirrorGradient;
  final double spotlightRadius;
  final double spotlightSoftness;
  final double spotlightOpacity;
  final double distortAmount;
  final String shineDirection; // 'left' or 'right'
  final BlendMode mixBlendMode;
  final Widget? child;

  const GradientBlinds({
    Key? key,
    required this.shader,
    this.gradientColors,
    this.paused = false,
    this.angle = 0,
    this.noise = 0.3,
    this.blindCount = 16,
    this.blindMinWidth = 60,
    this.mouseDampening = 0.15,
    this.mirrorGradient = false,
    this.spotlightRadius = 0.5,
    this.spotlightSoftness = 1.0,
    this.spotlightOpacity = 1.0,
    this.distortAmount = 0.0,
    this.shineDirection = 'left',
    this.mixBlendMode = BlendMode.srcOver,
    this.child,
  }) : super(key: key);

  @override
  State<GradientBlinds> createState() => _GradientBlindsState();
}

class _GradientBlindsState extends State<GradientBlinds> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _elapsedSeconds = 0.0;
  Offset _mouseTarget = Offset.zero;
  Offset _mouseCurrent = Offset.zero;
  bool _firstResize = true;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (!widget.paused) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant GradientBlinds oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused && _ticker.isTicking) {
      _ticker.stop();
    } else if (!widget.paused && !_ticker.isTicking) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (widget.paused) return;

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    _elapsedSeconds = elapsed.inMicroseconds / 1000000.0;

    if (widget.mouseDampening > 0) {
      final double tau = math.max(1e-4, widget.mouseDampening);
      double factor = 1.0 - math.exp(-dt / tau);
      if (factor > 1.0) factor = 1.0;

      _mouseCurrent = Offset(
        _mouseCurrent.dx + (_mouseTarget.dx - _mouseCurrent.dx) * factor,
        _mouseCurrent.dy + (_mouseTarget.dy - _mouseCurrent.dy) * factor,
      );
    } else {
      _mouseCurrent = _mouseTarget;
    }

    setState(() {});
  }

  List<List<double>> _prepStops(List<Color>? colors) {
    final baseColors = colors ?? [const Color(0xFFFF9FFC), const Color(0xff5227ff)];
    List<Color> working = List.from(baseColors);
    if (working.length > 8) working = working.sublist(0, 8);
    if (working.length == 1) working.add(working[0]);
    while (working.length < 8) {
      working.add(working.last);
    }

    return working.map((c) => [c.red / 255.0, c.green / 255.0, c.blue / 255.0]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_firstResize && size.width > 0 && size.height > 0) {
          _firstResize = false;
          final center = Offset(size.width / 2, size.height / 2);
          _mouseTarget = center;
          _mouseCurrent = center;
        }

        // Blind limits calculation based on min width layout constraints
        double effectiveBlindCount = widget.blindCount;
        if (widget.blindMinWidth > 0) {
          final maxByMinWidth = math.max(1.0, (size.width / widget.blindMinWidth).floorToDouble());
          effectiveBlindCount = widget.blindCount > 0 ? math.min(widget.blindCount, maxByMinWidth) : maxByMinWidth;
        }
        effectiveBlindCount = math.max(1.0, effectiveBlindCount);

        final preparedColors = _prepStops(widget.gradientColors);
        final colorCount = math.max(2.0, math.min(8.0, (widget.gradientColors?.length ?? 2).toDouble()));

        return MouseRegion(
          onHover: (event) {
            if (widget.mouseDampening <= 0) {
              _mouseCurrent = event.localPosition;
            }
            _mouseTarget = event.localPosition;
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: ShaderPainter(
              shader: widget.shader,
              resolution: size,
              mouse: _mouseCurrent,
              time: _elapsedSeconds,
              angle: (widget.angle * math.pi) / 180.0,
              noise: widget.noise,
              blindCount: effectiveBlindCount,
              spotlightRadius: widget.spotlightRadius,
              spotlightSoftness: widget.spotlightSoftness,
              spotlightOpacity: widget.spotlightOpacity,
              mirrorGradient: widget.mirrorGradient ? 1.0 : 0.0,
              distortAmount: widget.distortAmount,
              shineFlip: widget.shineDirection == 'right' ? 1.0 : 0.0,
              colors: preparedColors,
              colorCount: colorCount,
              mixBlendMode: widget.mixBlendMode,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final Size resolution;
  final Offset mouse;
  final double time;
  final double angle;
  final double noise;
  final double blindCount;
  final double spotlightRadius;
  final double spotlightSoftness;
  final double spotlightOpacity;
  final double mirrorGradient;
  final double distortAmount;
  final double shineFlip;
  final List<List<double>> colors;
  final double colorCount;
  final BlendMode mixBlendMode;

  ShaderPainter({
    required this.shader,
    required this.resolution,
    required this.mouse,
    required this.time,
    required this.angle,
    required this.noise,
    required this.blindCount,
    required this.spotlightRadius,
    required this.spotlightSoftness,
    required this.spotlightOpacity,
    required this.mirrorGradient,
    required this.distortAmount,
    required this.shineFlip,
    required this.colors,
    required this.colorCount,
    required this.mixBlendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pass uniforms in the precise layout index matching the .frag declarations
    shader.setFloat(0, resolution.width);
    shader.setFloat(1, resolution.height);
    shader.setFloat(2, 1.0); // iResolution.z

    shader.setFloat(3, mouse.dx);
    shader.setFloat(4, mouse.dy); // iMouse

    shader.setFloat(5, time); // iTime

    shader.setFloat(6, angle);
    shader.setFloat(7, noise);
    shader.setFloat(8, blindCount);
    shader.setFloat(9, spotlightRadius);
    shader.setFloat(10, spotlightSoftness);
    shader.setFloat(11, spotlightOpacity);
    shader.setFloat(12, mirrorGradient);
    shader.setFloat(13, distortAmount);
    shader.setFloat(14, shineFlip);

    // Dynamic extraction loops for uniform arrays
    int offset = 15;
    for (int i = 0; i < 8; i++) {
      shader.setFloat(offset++, colors[i][0]);
      shader.setFloat(offset++, colors[i][1]);
      shader.setFloat(offset++, colors[i][2]);
    }
    shader.setFloat(offset, colorCount);

    final paint = Paint()
      ..shader = shader
      ..blendMode = mixBlendMode;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => true;
}