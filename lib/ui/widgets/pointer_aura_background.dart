
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CleanGridBackground extends StatefulWidget {
  final Widget? child;

  final Color bgColor;
  final Color dotColor;
  final Color glowColor;

  final double dotSize;
  final double gap;
  final double proximity;
  final double strength;
  final double bounce;
  final double tension;
  final double stretch;
  final double shockRadius;
  final double shockStrength;

  final bool mouseInteraction;
  final bool clickShock;

  const CleanGridBackground({
    super.key,
    this.child,
    this.bgColor = const Color(0xFF070A10),
    this.dotColor = const Color(0xFF3A3446),
    this.glowColor = const Color(0xFF38BDF8),
    this.dotSize = 5.0,
    this.gap = 18.0,
    this.proximity = 140.0,
    this.strength = 1.0,
    this.bounce = 0.6,
    this.tension = 0.4,
    this.stretch = 0.5,
    this.shockRadius = 320.0,
    this.shockStrength = 5.0,
    this.mouseInteraction = true,
    this.clickShock = true,
  });

  @override
  State<CleanGridBackground> createState() =>
      _CleanGridBackgroundState();
}

class _Dot {
  final Offset original;

  Offset offset = Offset.zero;
  Offset velocity = Offset.zero;

  double energy = 0.0;

  _Dot(this.original);
}

class _Shock {
  final Offset position;
  final double startTime;

  _Shock(this.position, this.startTime);
}

class _CleanGridBackgroundState extends State<CleanGridBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final List<_Dot> _dots = [];
  final List<_Shock> _shocks = [];

  Size _lastSize = Size.zero;

  Offset _mouse = Offset.zero;
  Offset _mouseVelocity = Offset.zero;

  bool _mouseInside = false;

  double _lastFrame = 0.0;
  double _lastTick = 0.0;
  double _elapsed = 0.0;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // GRID INITIALIZATION
  // ------------------------------------------------------------

  void _initializeGrid(Size size) {
    if (size == _lastSize) return;

    _lastSize = size;
    _dots.clear();

    final double cell = widget.dotSize + widget.gap;

    final int columns = math.max(
      1,
      ((size.width + widget.gap) / cell).floor(),
    ).toInt();

    final int rows = math.max(
      1,
      ((size.height + widget.gap) / cell).floor(),
    ).toInt();

    final double gridWidth = columns * cell - widget.gap;
    final double gridHeight = rows * cell - widget.gap;

    final double startX =
        (size.width - gridWidth) / 2 + widget.dotSize / 2;

    final double startY =
        (size.height - gridHeight) / 2 + widget.dotSize / 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final position = Offset(
          startX + col * cell,
          startY + row * cell,
        );

        _dots.add(_Dot(position));
      }
    }
  }

  // ------------------------------------------------------------
  // MOUSE MOVEMENT
  // ------------------------------------------------------------

  void _onMouseMove(Offset position, Duration timestamp) {
    if (!widget.mouseInteraction) return;

    final double now =
        timestamp.inMicroseconds / 1000000.0;

    if (_mouseInside && _lastFrame > 0.0) {
      final double dt =
          math.max(0.004, now - _lastFrame).toDouble();

      final Offset velocity = (position - _mouse) / dt;

      _mouseVelocity = Offset(
        _mouseVelocity.dx +
            (velocity.dx - _mouseVelocity.dx) * 0.6,
        _mouseVelocity.dy +
            (velocity.dy - _mouseVelocity.dy) * 0.6,
      );
    } else {
      _mouseVelocity = Offset.zero;
    }

    _mouse = position;
    _mouseInside = true;
    _lastFrame = now;
  }

  void _onMouseExit(PointerEvent event) {
    _mouseInside = false;
    _lastFrame = 0.0;
  }

  // ------------------------------------------------------------
  // CLICK SHOCKWAVE
  // ------------------------------------------------------------

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.clickShock) return;

    _shocks.add(
      _Shock(
        event.localPosition,
        _elapsed,
      ),
    );

    if (_shocks.length > 6) {
      _shocks.removeAt(0);
    }
  }

  // ------------------------------------------------------------
  // PHYSICS SIMULATION
  // ------------------------------------------------------------

  void _onTick(Duration elapsed) {
    if (!mounted || _dots.isEmpty) return;

    final double now =
        elapsed.inMicroseconds / 1000000.0;

    final double dt = _lastTick == 0.0
        ? 1.0 / 60.0
        : (now - _lastTick).clamp(0.001, 0.033).toDouble();

    _lastTick = now;
    _elapsed = now;

    _simulate(dt);

    // Gradually stop pointer velocity.
    final double decay = math.exp(-dt / 0.08);

    _mouseVelocity *= decay;

    setState(() {});
  }

  void _simulate(double dt) {
    final double radius = widget.proximity;

    final double speed = _mouseVelocity.distance;

    final Offset direction = speed > 0.001
        ? _mouseVelocity / speed
        : Offset.zero;

    // Smoothly normalize mouse speed without tanh().
    final double normalizedSpeed = speed / 900.0;

    final double smoothSpeed = normalizedSpeed /
        math.sqrt(1.0 + normalizedSpeed * normalizedSpeed);

    final double drive = _mouseInside
        ? 6500.0 * smoothSpeed * widget.strength
        : 0.0;

    // Spring settings.
    final double damping = 12.0 + widget.bounce * 8.0;
    final double stiffness = 65.0 + widget.bounce * 45.0;

    // Neighbor coupling creates the jelly effect.
    final double coupling = widget.tension * 18.0;

    final double cell = widget.dotSize + widget.gap;

    final int columns = _lastSize.width > 0
        ? math.max(
            1,
            ((_lastSize.width + widget.gap) / cell).floor(),
          ).toInt()
        : 1;

    final int rows = (_dots.length / columns).ceil();

    final List<Offset> forces = List<Offset>.filled(
      _dots.length,
      Offset.zero,
    );

    // Calculate forces for every dot.
    for (int i = 0; i < _dots.length; i++) {
      final dot = _dots[i];

      final Offset position = dot.original + dot.offset;

      Offset force = Offset.zero;

      // Mouse influence.
      if (drive > 0.0) {
        final Offset difference = position - _mouse;
        final double distance = difference.distance;

        if (distance < radius) {
          final double normalized =
              (1.0 - distance / radius)
                  .clamp(0.0, 1.0)
                  .toDouble();

          final double falloff = normalized * normalized;

          final Offset radial = distance > 0.001
              ? difference / distance
              : Offset.zero;

          force += (direction + radial * 0.6) *
              (drive * falloff);
        }
      }

      // Click shockwaves.
      for (final shock in _shocks) {
        final double age = _elapsed - shock.startTime;

        final double front = age * 650.0;

        final Offset difference = position - shock.position;
        final double distance = difference.distance;

        final double width = cell * 1.4;

        final double waveDistance =
            (distance - front) / width;

        if (waveDistance.abs() < 3.0 && distance > 0.001) {
          final double normalizedWave = math.exp(
            -waveDistance * waveDistance,
          );

          final Offset radial = difference / distance;

          final double amplitude =
              widget.shockStrength *
              width *
              0.24 *
              normalizedWave;

          force += radial * amplitude * stiffness * 0.35;
        }
      }

      // Spring force pulls dots back to their original position.
      force -= dot.offset * stiffness;

      // Damping prevents endless oscillation.
      force -= dot.velocity * damping;

      // Neighbor coupling.
      if (coupling > 0.0) {
        final int row = i ~/ columns;
        final int col = i % columns;

        Offset neighborSum = Offset.zero;
        int neighbors = 0;

        void addNeighbor(int index) {
          if (index < 0 || index >= _dots.length) return;

          neighborSum += _dots[index].offset;
          neighbors++;
        }

        if (col > 0) addNeighbor(i - 1);
        if (col < columns - 1) addNeighbor(i + 1);
        if (row > 0) addNeighbor(i - columns);
        if (row < rows - 1) addNeighbor(i + columns);

        if (neighbors > 0) {
  force +=
      (neighborSum - dot.offset * neighbors.toDouble()) * coupling;
}
      }

      forces[i] = force;
    }

    // Integrate the physics.
    for (int i = 0; i < _dots.length; i++) {
      final dot = _dots[i];

      dot.velocity += forces[i] * dt;

      dot.offset += dot.velocity * dt;

      dot.energy = (
        dot.velocity.distance / 380.0 * 0.85 +
        dot.offset.distance / (cell * 2.2) * 0.35
      ).clamp(0.0, 1.0).toDouble();
    }

    // Remove finished shockwaves.
    _shocks.removeWhere((shock) {
      final double age = _elapsed - shock.startTime;

      return age * 650.0 >
          widget.shockRadius + cell * 5.0;
    });
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 1280.0,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 720.0,
        );

        _initializeGrid(size);

        return MouseRegion(
          onExit: _onMouseExit,
          child: Listener(
            behavior: HitTestBehavior.translucent,

            onPointerHover: (event) {
              _onMouseMove(
                event.localPosition,
                event.timeStamp,
              );
            },

            onPointerMove: (event) {
              _onMouseMove(
                event.localPosition,
                event.timeStamp,
              );
            },

            onPointerDown: _onPointerDown,

            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: widget.bgColor,
                ),

                CustomPaint(
                  painter: _DotGridPainter(
                    dots: _dots,
                    shocks: _shocks,
                    time: _elapsed,
                    dotColor: widget.dotColor,
                    glowColor: widget.glowColor,
                    dotSize: widget.dotSize,
                    stretch: widget.stretch,
                    shockRadius: widget.shockRadius,
                    mouse: _mouse,
                    mouseInside: _mouseInside,
                  ),
                  size: Size.infinite,
                ),

                if (widget.child != null)
                  widget.child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------------------
// CUSTOM PAINTER
// --------------------------------------------------------------

class _DotGridPainter extends CustomPainter {
  final List<_Dot> dots;
  final List<_Shock> shocks;

  final double time;
  final double dotSize;
  final double stretch;
  final double shockRadius;

  final Color dotColor;
  final Color glowColor;

  final Offset mouse;
  final bool mouseInside;

  _DotGridPainter({
    required this.dots,
    required this.shocks,
    required this.time,
    required this.dotColor,
    required this.glowColor,
    required this.dotSize,
    required this.stretch,
    required this.shockRadius,
    required this.mouse,
    required this.mouseInside,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double radius = dotSize / 2.0;

    // Draw dots.
    for (final dot in dots) {
      final Offset position = dot.original + dot.offset;

      final double energy = dot.energy;

      final Color color = Color.lerp(
        dotColor,
        glowColor,
        (energy * 1.2).clamp(0.0, 1.0).toDouble(),
      )!;

      final double velocity = dot.velocity.distance;

      final double angle = velocity > 0.001
          ? math.atan2(
              dot.velocity.dy,
              dot.velocity.dx,
            )
          : 0.0;

      // Stretch according to movement speed.
      final double stretchAmount = math.min(
        dotSize * 2.0,
        velocity * stretch * 0.02,
      ).toDouble();

      final double width = dotSize + stretchAmount;

      // Glow around active dots.
      if (energy > 0.03) {
        glowPaint
          ..color = glowColor.withValues(
            alpha: energy * 0.35,
          )
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            radius * 2.0,
          );

        canvas.drawCircle(
          position,
          radius * (1.0 + energy * 1.5),
          glowPaint,
        );
      }

      // Draw stretched dot.
      canvas.save();

      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle);

      basePaint.color = color;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: width,
          height: dotSize,
        ),
        basePaint,
      );

      canvas.restore();
    }

    // Draw expanding click shockwaves.
    final shockPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    for (final shock in shocks) {
      final double age = time - shock.startTime;

      final double front = age * 650.0;

      final double progress = (
        1.0 - front / shockRadius
      ).clamp(0.0, 1.0).toDouble();

      shockPaint.color = glowColor.withValues(
        alpha: progress * 0.3,
      );

      canvas.drawCircle(
        shock.position,
        front,
        shockPaint,
      );
    }

    // Optional subtle cursor glow.
    if (mouseInside) {
      final cursorGlow = Paint()
        ..color = glowColor.withValues(alpha: 0.045)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          35.0,
        );

      canvas.drawCircle(
        mouse,
        45.0,
        cursorGlow,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _DotGridPainter oldDelegate,
  ) {
    return true;
  }
}
