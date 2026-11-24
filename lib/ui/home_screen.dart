import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rayar_mohan/core/helper_functions.dart';
import 'package:rayar_mohan/ui/widgets/education_section.dart';
import 'package:rayar_mohan/ui/widgets/experience_section.dart';
import 'package:rayar_mohan/ui/widgets/home_shining_nav_buttons.dart';
import 'package:rayar_mohan/ui/widgets/pointer_aura_background.dart';
import 'package:rayar_mohan/ui/widgets/shining_button.dart';
import 'package:rayar_mohan/ui/widgets/what_i_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ─────────────────────────────────────────────────────────────
// AnimatedOnScroll  –  reusable fade + slide wrapper
// ─────────────────────────────────────────────────────────────
class AnimatedOnScroll extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset slideFrom;
  final Duration duration;

  const AnimatedOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideFrom = const Offset(0, 50),
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedOnScroll> createState() => _AnimatedOnScrollState();
}

class _AnimatedOnScrollState extends State<AnimatedOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _trigger() {
    if (_triggered) return;
    _triggered = true;
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.08) _trigger();
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => FadeTransition(
          opacity: _fade,
          child: Transform.translate(offset: _slide.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CodeEditorAnimation  –  animated developer code editor window
// ─────────────────────────────────────────────────────────────
class CodeEditorAnimation extends StatefulWidget {
  const CodeEditorAnimation({super.key});

  @override
  State<CodeEditorAnimation> createState() => _CodeEditorAnimationState();
}

class _CodeEditorAnimationState extends State<CodeEditorAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CodeEditorPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CodeSegment {
  final String text;
  final Color color;
  const _CodeSegment(this.text, this.color);
}

class _CodeLine {
  final int indent;
  final List<_CodeSegment> segments;
  const _CodeLine(this.indent, this.segments);
}

class _FloatingGlyph {
  final String text;
  final double relX;
  final double relY;
  final double speed;
  final Color color;
  const _FloatingGlyph(this.text, this.relX, this.relY, this.speed, this.color);
}

class _CodeEditorPainter extends CustomPainter {
  final double t;
  _CodeEditorPainter(this.t);

  static const Color _kw = Color(0xFF7C9CFF);
  static const Color _type = Color(0xFF4FD1C5);
  static const Color _str = Color(0xFFA9D606);
  static const Color _prop = Color(0xFFE6E9EF);
  static const Color _punc = Color(0xFF8A93A6);

  static const List<_CodeLine> _code = [
    _CodeLine(0, [
      _CodeSegment('class ', _kw),
      _CodeSegment('Developer', _type),
      _CodeSegment(' {', _punc),
    ]),
    _CodeLine(1, [
      _CodeSegment('final ', _kw),
      _CodeSegment('name', _prop),
      _CodeSegment(' = ', _punc),
      _CodeSegment("'Rayar Mohan'", _str),
      _CodeSegment(';', _punc),
    ]),
    _CodeLine(1, [
      _CodeSegment('final ', _kw),
      _CodeSegment('role', _prop),
      _CodeSegment(' = ', _punc),
      _CodeSegment("'Flutter Developer'", _str),
      _CodeSegment(';', _punc),
    ]),
    _CodeLine(0, []),
    _CodeLine(1, [
      _CodeSegment('Widget ', _type),
      _CodeSegment('build', _prop),
      _CodeSegment('() {', _punc),
    ]),
    _CodeLine(2, [
      _CodeSegment('return ', _kw),
      _CodeSegment('FlutterApp', _type),
      _CodeSegment('(', _punc),
    ]),
    _CodeLine(3, [
      _CodeSegment('skills', _prop),
      _CodeSegment(': ', _punc),
      _CodeSegment("['Dart', 'Flutter']", _str),
      _CodeSegment(',', _punc),
    ]),
    _CodeLine(3, [
      _CodeSegment('passion', _prop),
      _CodeSegment(': ', _punc),
      _CodeSegment('true', _kw),
      _CodeSegment(',', _punc),
    ]),
    _CodeLine(2, [
      _CodeSegment(');', _punc),
    ]),
    _CodeLine(1, [
      _CodeSegment('}', _punc),
    ]),
    _CodeLine(0, [
      _CodeSegment('}', _punc),
    ]),
  ];

  static final int _totalChars = _code.fold<int>(
    0,
    (sum, line) =>
        sum + line.segments.fold<int>(0, (s, seg) => s + seg.text.length) + 1,
  );

  static const List<_FloatingGlyph> _glyphs = [
    _FloatingGlyph('</>', 0.12, 0.15, 0.55, Color(0xFF7C9CFF)),
    _FloatingGlyph('{ }', 0.87, 0.20, 0.42, Color(0xFFC792EA)),
    _FloatingGlyph('=>', 0.09, 0.83, 0.50, Color(0xFFA9D606)),
    _FloatingGlyph('()', 0.89, 0.80, 0.68, Color(0xFF4FD1C5)),
    _FloatingGlyph('[]', 0.22, 0.93, 0.38, Color(0xFFC792EA)),
    _FloatingGlyph('const', 0.79, 0.10, 0.34, Color(0xFF7C9CFF)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _paintGlowOrbs(canvas, size);
    _paintGlyphs(canvas, size);

    final double cardW = size.width * 0.88;
    final double cardH = size.height * 0.70;
    final double bob = math.sin(t * 2 * math.pi) * size.height * 0.012;
    final Rect card = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + bob),
      width: cardW,
      height: cardH,
    );

    _paintCard(canvas, card, cardW);
    _paintTitleBar(canvas, card, cardW, cardH);
    _paintCode(canvas, card, cardW, cardH);
    _paintStatusBar(canvas, card, cardW, cardH);
  }

  void _paintGlowOrbs(Canvas canvas, Size size) {
    final c1 = Offset(
      size.width * (0.30 + 0.03 * math.sin(t * 2 * math.pi)),
      size.height * (0.32 + 0.03 * math.cos(t * 2 * math.pi)),
    );
    final c2 = Offset(
      size.width * (0.72 + 0.03 * math.cos(t * 2 * math.pi)),
      size.height * (0.70 + 0.03 * math.sin(t * 2 * math.pi)),
    );
    _orb(canvas, c1, size.width * 0.30,
        const Color(0xFF2E43FF).withValues(alpha: 0.22));
    _orb(canvas, c2, size.width * 0.28,
        const Color(0xFF9A5BFF).withValues(alpha: 0.18));
  }

  void _orb(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
    );
  }

  void _paintGlyphs(Canvas canvas, Size size) {
    for (final g in _glyphs) {
      final angle = t * 2 * math.pi * g.speed + g.relX * 6.28;
      final x = size.width * g.relX + math.sin(angle) * 10;
      final y = size.height * g.relY + math.cos(angle) * 10;
      final opacity = 0.10 + 0.08 * (math.sin(angle) * 0.5 + 0.5);
      final tp = TextPainter(
        text: TextSpan(
          text: g.text,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w600,
            color: g.color.withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  void _paintCard(Canvas canvas, Rect card, double cardW) {
    final rrect =
        RRect.fromRectAndRadius(card, Radius.circular(cardW * 0.045));

    canvas.drawRRect(
      rrect.inflate(2),
      Paint()
        ..color = const Color(0xFF2E43FF).withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F141C), Color(0xFF161C28)],
        ).createShader(card),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4FD1C5).withValues(alpha: 0.55),
            const Color(0xFF7C9CFF).withValues(alpha: 0.35),
            const Color(0xFFC792EA).withValues(alpha: 0.45),
          ],
        ).createShader(card),
    );
  }

  void _paintTitleBar(Canvas canvas, Rect card, double cardW, double cardH) {
    final double titleH = cardH * 0.11;
    final double dotR = math.max(2.5, cardW * 0.009);
    final double y = card.top + titleH * 0.5;

    const dotColors = [
      Color(0xFFFF5F57),
      Color(0xFFFFBD2E),
      Color(0xFF28C840),
    ];
    double x = card.left + cardW * 0.045;
    for (final c in dotColors) {
      canvas.drawCircle(Offset(x, y), dotR,
          Paint()..color = c.withValues(alpha: 0.9));
      x += dotR * 2.8;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'rayar_mohan.dart',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: math.max(8, cardW * 0.032),
          color: const Color(0xFF8A93A6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(card.left + cardW - tp.width - cardW * 0.045, y - tp.height / 2),
    );

    canvas.drawLine(
      Offset(card.left, card.top + titleH),
      Offset(card.right, card.top + titleH),
      Paint()
        ..color = const Color(0xFF2A3140).withValues(alpha: 0.9)
        ..strokeWidth = 1,
    );
  }

  void _paintCode(Canvas canvas, Rect card, double cardW, double cardH) {
    final double titleH = cardH * 0.11;
    final double statusH = cardH * 0.09;
    final double fontPx = (cardH / 24).clamp(7.0, 15.0);
    final double available = cardH - titleH - statusH - fontPx * 1.2;
    final double lineHeight =
        math.min(fontPx * 1.55, available / _code.length);
    final double gutterRight = card.left + cardW * 0.13;
    final double codeLeft = gutterRight + cardW * 0.03;
    final double indentW = fontPx * 1.4;
    final double firstLineY = card.top + titleH + fontPx * 1.15;

    const double cycle = 0.72;
    final double progress = (t / cycle).clamp(0.0, 1.0);
    final int visible = (progress * _totalChars).floor();

    int budget = visible;
    int caretLine = -1;
    double caretX = 0;
    double caretY = 0;

    for (int i = 0; i < _code.length; i++) {
      if (budget <= 0 && i > 0) break;

      final line = _code[i];
      final double y = firstLineY + i * lineHeight;

      final numberTp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontPx * 0.8,
            color: const Color(0xFF5A6472),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numberTp.paint(
        canvas,
        Offset(gutterRight - numberTp.width,
            y + (fontPx - numberTp.height) * 0.5),
      );

      double x = codeLeft + line.indent * indentW;
      bool partial = false;

      for (final seg in line.segments) {
        if (budget <= 0) {
          partial = true;
          break;
        }
        final take = math.min(budget, seg.text.length);
        final visibleText = seg.text.substring(0, take);
        if (visibleText.isNotEmpty) {
          final tp = TextPainter(
            text: TextSpan(
              text: visibleText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontPx,
                color: seg.color,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x, y));
          x += tp.width;
        }
        budget -= take;
        if (take < seg.text.length) {
          partial = true;
          break;
        }
      }

      if (partial || budget == 0) {
        caretLine = i;
        caretX = x;
        caretY = y;
        break;
      }

      budget -= 1;
      if (budget == 0) {
        caretLine = i;
        caretX = x;
        caretY = y;
        break;
      }
    }

    if (caretLine >= 0) {
      final double indicatorY = firstLineY + caretLine * lineHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(card.left + cardW * 0.035, indicatorY,
              fontPx * 0.22, lineHeight * 0.8),
          Radius.circular(fontPx * 0.12),
        ),
        Paint()..color = const Color(0xFF4FD1C5).withValues(alpha: 0.8),
      );

      final double blink = (math.sin(t * 2 * math.pi * 8) + 1) / 2;
      final double caretOpacity = blink > 0.5 ? 0.95 : 0.15;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(caretX + 1, caretY,
              math.max(1.8, fontPx * 0.11), fontPx * 1.15),
          const Radius.circular(1),
        ),
        Paint()..color = const Color(0xFFA9D606).withValues(alpha: caretOpacity),
      );
    }
  }

  void _paintStatusBar(Canvas canvas, Rect card, double cardW, double cardH) {
    final double statusH = cardH * 0.09;
    final double y = card.bottom - statusH;

    canvas.drawLine(
      Offset(card.left, y),
      Offset(card.right, y),
      Paint()
        ..color = const Color(0xFF2A3140).withValues(alpha: 0.9)
        ..strokeWidth = 1,
    );

    final double dotR = math.max(2.0, cardW * 0.007);
    final double dotX = card.left + cardW * 0.045;
    final double centerY = y + statusH * 0.5;
    canvas.drawCircle(
        Offset(dotX, centerY), dotR, Paint()..color = const Color(0xFF28C840));

    final tp = TextPainter(
      text: TextSpan(
        text: 'main.dart   •   Dart',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: math.max(8, cardW * 0.026),
          color: const Color(0xFF8A93A6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(dotX + dotR * 2.5, centerY - tp.height / 2));

    final rightTp = TextPainter(
      text: TextSpan(
        text: 'UTF-8',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: math.max(8, cardW * 0.026),
          color: const Color(0xFF5A6472),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rightTp.paint(
      canvas,
      Offset(card.right - rightTp.width - cardW * 0.045,
          centerY - rightTp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CodeEditorPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────
// MobileAppAnimation  –  floating phone with a live app UI
// ─────────────────────────────────────────────────────────────
class MobileAppAnimation extends StatefulWidget {
  const MobileAppAnimation({super.key});

  @override
  State<MobileAppAnimation> createState() => _MobileAppAnimationState();
}

class _MobileAppAnimationState extends State<MobileAppAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 9))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _MobileAppPainter(_controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _TechChip {
  final String label;
  final double relX;
  final double relY;
  final double phase;
  final Color color;
  const _TechChip(this.label, this.relX, this.relY, this.phase, this.color);
}

class _MobileAppPainter extends CustomPainter {
  final double t;
  _MobileAppPainter(this.t);

  static const Color _blue = Color(0xFF5B8CFF);
  static const Color _cyan = Color(0xFF4FD1C5);
  static const Color _purple = Color(0xFFC792EA);
  static const Color _green = Color(0xFFA9D606);
  static const Color _amber = Color(0xFFFFBD2E);
  static const Color _white = Color(0xFFE6E9EF);

  static const List<_TechChip> _chips = [
    _TechChip('Flutter', 0.16, 0.30, 0.0, _cyan),
    _TechChip('Dart', 0.84, 0.24, 1.3, _blue),
    _TechChip('iOS', 0.14, 0.68, 2.1, _white),
    _TechChip('Android', 0.85, 0.72, 2.9, _green),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _paintBackground(canvas, size);
    _paintPhone(canvas, size);
    _paintChips(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final c1 = Offset(
      size.width * (0.32 + 0.03 * math.sin(t * 2 * math.pi)),
      size.height * (0.30 + 0.03 * math.cos(t * 2 * math.pi)),
    );
    final c2 = Offset(
      size.width * (0.70 + 0.03 * math.cos(t * 2 * math.pi)),
      size.height * (0.72 + 0.03 * math.sin(t * 2 * math.pi)),
    );
    _orb(canvas, c1, size.width * 0.30, _blue.withValues(alpha: 0.20));
    _orb(canvas, c2, size.width * 0.28, _purple.withValues(alpha: 0.16));

    for (int i = 0; i < 18; i++) {
      final double bx = ((i * 37) % 100) / 100;
      final double by = ((i * 61) % 100) / 100;
      final double phase = i * 0.7;
      final double x =
          size.width * bx + math.sin(t * 2 * math.pi * 0.5 + phase) * 8;
      final double y =
          size.height * by + math.cos(t * 2 * math.pi * 0.5 + phase) * 8;
      final double opacity =
          0.08 + 0.10 * (math.sin(t * 2 * math.pi * 0.8 + phase) * 0.5 + 0.5);
      final color = i.isEven ? _blue : _purple;
      canvas.drawCircle(
        Offset(x, y),
        (0.6 + (i % 3) * 0.5) * (size.width / 500),
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  void _orb(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
    );
  }

  void _paintPhone(Canvas canvas, Size size) {
    final double pw = size.width * 0.36;
    final double ph = pw * 2.05;
    final double bob = math.sin(t * 2 * math.pi) * size.height * 0.02;
    final Offset center = Offset(size.width * 0.5, size.height * 0.5 + bob);
    final Rect phone = Rect.fromCenter(center: center, width: pw, height: ph);
    final RRect frame =
        RRect.fromRectAndRadius(phone, Radius.circular(pw * 0.20));

    canvas.drawRRect(
      frame.inflate(3),
      Paint()
        ..color = _blue.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232A38), Color(0xFF0D1017)],
        ).createShader(phone),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pw * 0.012
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cyan.withValues(alpha: 0.8),
            _blue.withValues(alpha: 0.6),
            _purple.withValues(alpha: 0.7),
          ],
        ).createShader(phone),
    );

    final double bezel = pw * 0.05;
    final Rect screen = phone.deflate(bezel);
    final RRect screenRR =
        RRect.fromRectAndRadius(screen, Radius.circular(pw * 0.15));

    canvas.save();
    canvas.clipRRect(screenRR);
    canvas.drawRect(
      screen,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1626), Color(0xFF111A2E)],
        ).createShader(screen),
    );
    _paintScreenUI(canvas, screen);
    canvas.restore();

    canvas.drawRRect(
      screenRR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _white.withValues(alpha: 0.06),
    );

    final double islandW = pw * 0.30;
    final double islandH = pw * 0.075;
    final Rect island = Rect.fromCenter(
      center: Offset(center.dx, screen.top + islandH * 1.1),
      width: islandW,
      height: islandH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(island, Radius.circular(islandH / 2)),
      Paint()..color = const Color(0xFF05070B),
    );
    canvas.drawCircle(
      Offset(island.right - islandH * 0.6, island.center.dy),
      islandH * 0.18,
      Paint()..color = _cyan.withValues(alpha: 0.8),
    );
  }

  void _paintScreenUI(Canvas canvas, Rect screen) {
    final double sw = screen.width;
    final double sh = screen.height;
    final double pad = sw * 0.08;

    final Rect header = Rect.fromLTWH(
      screen.left + pad,
      screen.top + sh * 0.11,
      sw - pad * 2,
      sh * 0.20,
    );
    final RRect headerRR =
        RRect.fromRectAndRadius(header, Radius.circular(sw * 0.06));

    canvas.drawRRect(
      headerRR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withValues(alpha: 0.95),
            _purple.withValues(alpha: 0.85),
          ],
        ).createShader(header),
    );

    final double sheen = (t * 1.6) % 1.0;
    canvas.save();
    canvas.clipRRect(headerRR);
    canvas.drawRect(
      header,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.5 + sheen * 3, -1),
          end: Alignment(sheen * 3, 1),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.35, 0.5, 0.65],
        ).createShader(header),
    );
    canvas.restore();

    final TextPainter title = TextPainter(
      text: TextSpan(
        text: 'My Apps',
        style: TextStyle(
          fontSize: sw * 0.12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(
      canvas,
      Offset(header.left + sw * 0.06, header.top + header.height * 0.18),
    );

    final TextPainter subtitle = TextPainter(
      text: TextSpan(
        text: 'Built with Flutter',
        style: TextStyle(
          fontSize: sw * 0.06,
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    subtitle.paint(
      canvas,
      Offset(header.left + sw * 0.06, header.top + header.height * 0.60),
    );

    final double avatarR = header.height * 0.20;
    final Offset avatarCenter =
        Offset(header.right - sw * 0.09, header.top + header.height * 0.32);
    canvas.drawCircle(avatarCenter, avatarR,
        Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.drawCircle(avatarCenter, avatarR * 0.55,
        Paint()..color = Colors.white.withValues(alpha: 0.85));

    final double labelY = header.bottom + sh * 0.055;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(screen.left + pad, labelY, sw * 0.34, sh * 0.028),
        Radius.circular(sh * 0.014),
      ),
      Paint()..color = _white.withValues(alpha: 0.35),
    );

    final double cardH = sh * 0.11;
    final double gap = sh * 0.025;
    double y = labelY + sh * 0.028 + sh * 0.035;
    final List<List<Color>> gradients = [
      [_cyan, _blue],
      [_purple, _blue],
      [_amber, _purple],
    ];
    for (int i = 0; i < 3; i++) {
      _projectCard(
        canvas,
        Rect.fromLTWH(screen.left + pad, y, sw - pad * 2, cardH),
        gradients[i],
        i == 0,
      );
      y += cardH + gap;
    }

    final double navH = sh * 0.10;
    final Rect nav = Rect.fromLTWH(
      screen.left + pad,
      screen.bottom - navH - sh * 0.05,
      sw - pad * 2,
      navH,
    );
    final RRect navRR =
        RRect.fromRectAndRadius(nav, Radius.circular(navH * 0.5));
    canvas.drawRRect(navRR, Paint()..color = const Color(0xFF0D1626));
    canvas.drawRRect(
      navRR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _white.withValues(alpha: 0.07),
    );

    final double slot = nav.width / 3;
    for (int i = 0; i < 3; i++) {
      final Offset c = Offset(nav.left + slot * (i + 0.5), nav.center.dy);
      if (i == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: navH * 0.95, height: navH * 0.72),
            Radius.circular(navH * 0.36),
          ),
          Paint()..color = _blue.withValues(alpha: 0.22),
        );
      }
      _navIcon(canvas, c, navH, i,
          i == 0 ? _blue : _white.withValues(alpha: 0.28));
    }

    final double fabR = sw * 0.085;
    final Offset fabCenter =
        Offset(screen.right - pad - fabR, nav.top - fabR * 1.35);
    final double pulse = 1 + 0.06 * math.sin(t * 2 * math.pi * 3);
    canvas.drawCircle(
      fabCenter,
      fabR * 1.5,
      Paint()
        ..color = _blue.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      fabCenter,
      fabR * pulse,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue, _purple],
        ).createShader(Rect.fromCircle(center: fabCenter, radius: fabR)),
    );
    final plusPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(1.5, fabR * 0.16)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(fabCenter.translate(-fabR * 0.4, 0),
        fabCenter.translate(fabR * 0.4, 0), plusPaint);
    canvas.drawLine(fabCenter.translate(0, -fabR * 0.4),
        fabCenter.translate(0, fabR * 0.4), plusPaint);
  }

  void _projectCard(
      Canvas canvas, Rect rect, List<Color> gradient, bool featured) {
    final RRect rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.22));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF131C2C));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _white.withValues(alpha: 0.06),
    );

    final double thumbSize = rect.height * 0.66;
    final Rect thumb = Rect.fromLTWH(
      rect.left + rect.height * 0.2,
      rect.center.dy - thumbSize / 2,
      thumbSize,
      thumbSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumb, Radius.circular(thumbSize * 0.28)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ).createShader(thumb),
    );

    final double textLeft = thumb.right + rect.height * 0.18;
    final double barH = rect.height * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            textLeft, rect.center.dy - barH * 1.6, rect.width * 0.42, barH),
        Radius.circular(barH * 0.5),
      ),
      Paint()..color = _white.withValues(alpha: 0.80),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            textLeft, rect.center.dy + barH * 0.4, rect.width * 0.28, barH * 0.75),
        Radius.circular(barH * 0.4),
      ),
      Paint()..color = _white.withValues(alpha: 0.30),
    );

    if (featured) {
      final Rect pill = Rect.fromLTWH(
        rect.right - rect.width * 0.20,
        rect.center.dy - barH * 0.55,
        rect.width * 0.13,
        barH * 1.1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pill, Radius.circular(pill.height / 2)),
        Paint()..color = _green.withValues(alpha: 0.22),
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: 'LIVE',
          style: TextStyle(
            fontSize: pill.height * 0.6,
            fontWeight: FontWeight.w700,
            color: _green,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(pill.center.dx - tp.width / 2, pill.center.dy - tp.height / 2),
      );
    }
  }

  void _navIcon(Canvas canvas, Offset c, double navH, int index, Color color) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, navH * 0.06)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double s = navH * 0.18;

    if (index == 0) {
      final Path path = Path()
        ..moveTo(c.dx - s, c.dy)
        ..lineTo(c.dx, c.dy - s)
        ..lineTo(c.dx + s, c.dy)
        ..moveTo(c.dx - s * 0.7, c.dy)
        ..lineTo(c.dx - s * 0.7, c.dy + s * 0.8)
        ..lineTo(c.dx + s * 0.7, c.dy + s * 0.8)
        ..lineTo(c.dx + s * 0.7, c.dy);
      canvas.drawPath(path, p);
    } else if (index == 1) {
      canvas.drawCircle(c.translate(-s * 0.2, -s * 0.2), s * 0.7, p);
      canvas.drawLine(
          c.translate(s * 0.3, s * 0.3), c.translate(s * 0.9, s * 0.9), p);
    } else {
      canvas.drawCircle(c.translate(0, -s * 0.35), s * 0.5, p);
      canvas.drawArc(
        Rect.fromCenter(
            center: c.translate(0, s * 0.9), width: s * 1.8, height: s * 1.6),
        math.pi,
        math.pi,
        false,
        p,
      );
    }
  }

  void _paintChips(Canvas canvas, Size size) {
    final double fs = (size.width * 0.028).clamp(9.0, 15.0);
    for (final chip in _chips) {
      final double angle = t * 2 * math.pi + chip.phase;
      final double x =
          size.width * chip.relX + math.cos(angle) * size.width * 0.008;
      final double y =
          size.height * chip.relY + math.sin(angle) * size.height * 0.016;
      _chip(canvas, Offset(x, y), chip.label, chip.color, fs);
    }
  }

  void _chip(
      Canvas canvas, Offset center, String label, Color color, double fs) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fs,
          fontWeight: FontWeight.w600,
          color: _white.withValues(alpha: 0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double padX = fs * 0.85;
    final double padY = fs * 0.5;
    final double dotR = fs * 0.28;
    final double gap = fs * 0.45;
    final double w = padX * 2 + dotR * 2 + gap + tp.width;
    final double h = tp.height + padY * 2;
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      Radius.circular(h / 2),
    );

    canvas.drawRRect(
      rrect.inflate(1),
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(rrect,
        Paint()..color = const Color(0xFF111826).withValues(alpha: 0.92));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(rrect.left + padX + dotR, center.dy),
      dotR,
      Paint()..color = color,
    );
    tp.paint(
      canvas,
      Offset(rrect.left + padX + dotR * 2 + gap, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MobileAppPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final ui.FragmentShader shader;
  const HomeScreen({super.key, required this.shader});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _skillsKey     = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _educationKey  = GlobalKey();
  final GlobalKey _contactKey    = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        _socialAvatar('assets/github_logo.png',  'https://github.com/Rayarmohan'),
        const SizedBox(width: 20),
        _socialAvatar('assets/gmail_logo.jpg',   'mailto:mohanmanu0862@gmail.com'),
        const SizedBox(width: 20),
        _socialAvatar('assets/linkedin_logo.png','https://in.linkedin.com/in/rayarmohan'),
        const SizedBox(width: 20),
        _socialAvatar('assets/whatsapp.png',     'https://wa.me/918921358229'),
      ],
    );
  }

  Widget _socialAvatar(String asset, String url) {
    return InkWell(
      onTap: () => launchURL(url),
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(asset),
      ),
    );
  }

  List<Widget> _navButtons() {
    return [
      HoverShiningNavButton(text: 'Skills',          onTap: () => _scrollToKey(_skillsKey)),
      HoverShiningNavButton(text: 'Work Experience', onTap: () => _scrollToKey(_experienceKey)),
      HoverShiningNavButton(text: 'Education',       onTap: () => _scrollToKey(_educationKey)),
      HoverShiningNavButton(text: 'Contact me',      onTap: () => _scrollToKey(_contactKey)),
    ];
  }

  Widget _buildNavbar(
    bool isSmall,
    bool isMedium,
    bool isLarge,
    TextTheme textTheme,
  ) {
    final List<Widget> navButtons = _navButtons();

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: navButtons,
          ),
        ],
      );
    }

    if (isMedium) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: navButtons,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Flexible(
          flex: 3,
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: navButtons,
          ),
        ),
      ],
    );
  }

  Widget _buildName(TextTheme textTheme, double nameFontSize) {
    return AnimatedOnScroll(
      key: const ValueKey('hero_name'),
      delay: const Duration(milliseconds: 100),
      slideFrom: const Offset(0, 40),
      child: Text(
        'Rayar Mohan',
        style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
      ),
    );
  }

  Widget _buildTextBlock(
    BuildContext context,
    TextTheme textTheme,
    double nameFontSize,
    double roleFontSize,
    double screenWidth, {
    bool showName = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName) ...[
          const SizedBox(height: 25),
          _buildName(textTheme, nameFontSize),
          const SizedBox(height: 20),
        ],

        AnimatedOnScroll(
          key: const ValueKey('hero_role'),
          delay: const Duration(milliseconds: 220),
          slideFrom: const Offset(0, 35),
          child: Text(
            'Mobile App Developer',
            style: textTheme.headlineLarge!
                .copyWith(fontSize: roleFontSize, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        AnimatedOnScroll(
          key: const ValueKey('hero_bio'),
          delay: const Duration(milliseconds: 340),
          slideFrom: const Offset(0, 30),
          child: Text(
            'Mobile App Developer skilled in crafting efficient Flutter applications for Android and iOS. '
            'Proficient in designing and developing scalable, high-performance mobile solutions with clean architecture. '
            'Strong foundation in state management, REST APIs, payment integrations, and real-time features. '
            'Eager collaborator committed to delivering high-quality products in fast-paced, team-oriented environments.',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.left,
          ),
        ),

        const SizedBox(height: 28),

        AnimatedOnScroll(
          key: const ValueKey('hero_social'),
          delay: const Duration(milliseconds: 460),
          slideFrom: const Offset(0, 25),
          child: _buildSocialRow(),
        ),

        const SizedBox(height: 20),

        AnimatedOnScroll(
          key: const ValueKey('hero_resume'),
          delay: const Duration(milliseconds: 560),
          slideFrom: const Offset(0, 20),
          child: Row(
            children: [
              ShiningButton(
                text: 'Download My RESUME',
                onTap: () async {
                  final Uri url = Uri.parse('https://rayarmohan.github.io/assets/assets/rayar_mohan.pdf');
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    await launchUrl(
                      Uri.parse('https://rayarmohan.github.io/assets/rayar_mohan.pdf'),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatIDoTextBlock(
    BuildContext context,
    TextTheme textTheme,
    double nameFontSize,
    double roleFontSize,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),

        AnimatedOnScroll(
          key: const ValueKey('skills_heading'),
          slideFrom: const Offset(-60, 0),
          child: Text(
            'What I Do',
            style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
          ),
        ),

        const SizedBox(height: 20),

        AnimatedOnScroll(
          key: const ValueKey('skills_list'),
          delay: const Duration(milliseconds: 150),
          slideFrom: const Offset(0, 40),
          child: WhatIDoSection(),
        ),

        const SizedBox(height: 50),

        AnimatedOnScroll(
          key: const ValueKey('skills_stack'),
          delay: const Duration(milliseconds: 300),
          slideFrom: const Offset(0, 30),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/flutter.jpg')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/android.jpg')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/ios.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/dart.jpg')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/firebase.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/cloudg.jpeg')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/git.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/postman.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/figma.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/aws.png')),
              CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('assets/stripe.png')),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme    = Theme.of(context).textTheme;
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isLarge  = screenWidth >= 1100;
    final bool isMedium = screenWidth >= 700 && screenWidth < 1100;
    final bool isSmall  = screenWidth < 700;

    final double nameFontSize  = isLarge ? 90 : isMedium ? 60 : 40;
    final double roleFontSize  = isLarge ? 60 : isMedium ? 40 : 28;
    final double horizontalPad = isLarge ? 50 : isMedium ? 30 : 16;
    final double lottieSize    = isLarge ? 500 : isMedium ? 360 : 280;
    final double lottieOffset  = isLarge ? 0 : isMedium ? -20 : 0;
    final double lottie2Offset = isLarge ? 40 : isMedium ? 10 : 0;

    final scrollContent = SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          top: 50,
          right: horizontalPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSmall)
              AnimatedOnScroll(
                key: const ValueKey('navbar'),
                slideFrom: const Offset(0, -30),
                duration: const Duration(milliseconds: 500),
                child: _buildNavbar(isSmall, isMedium, isLarge, textTheme),
              ),

            if (isSmall) const SizedBox(height: 60),

            isSmall
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOnScroll(
                        key: const ValueKey('hero_lottie_small'),
                        slideFrom: const Offset(0, -40),
                        duration: const Duration(milliseconds: 800),
                        child: Center(
                          child: SizedBox(
                            width: lottieSize,
                            height: lottieSize,
                            child: const CodeEditorAnimation(),
                          ),
                        ),
                      ),
                      _buildTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildName(textTheme, nameFontSize),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AnimatedOnScroll(
                                key: const ValueKey('navbar'),
                                slideFrom: const Offset(0, -30),
                                duration: const Duration(milliseconds: 500),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.end,
                                  children: _navButtons(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextBlock(
                              context,
                              textTheme,
                              nameFontSize,
                              roleFontSize,
                              screenWidth,
                              showName: false,
                            ),
                          ),
                          AnimatedOnScroll(
                            key: const ValueKey('hero_lottie'),
                            slideFrom: const Offset(80, 0),
                            duration: const Duration(milliseconds: 900),
                            child: Transform.translate(
                              offset: Offset(0, lottieOffset),
                              child: SizedBox(
                                width: lottieSize,
                                height: lottieSize,
                                child: const CodeEditorAnimation(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

            SizedBox(height: screenHeight * 0.15),

            isSmall
                ? Column(
                    key: _skillsKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWhatIDoTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
                      AnimatedOnScroll(
                        key: const ValueKey('skills_lottie_small'),
                        slideFrom: const Offset(0, 50),
                        child: Center(
                          child: SizedBox(
                            width: lottieSize,
                            height: lottieSize,
                            child: const MobileAppAnimation(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: _skillsKey,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedOnScroll(
                        key: const ValueKey('skills_lottie'),
                        slideFrom: const Offset(-80, 0),
                        duration: const Duration(milliseconds: 900),
                        child: Transform.translate(
                          offset: Offset(0, lottie2Offset),
                          child: SizedBox(
                            width: lottieSize,
                            height: lottieSize,
                            child: const MobileAppAnimation(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildWhatIDoTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
                      ),
                    ],
                  ),

            SizedBox(height: screenHeight * .20),

            AnimatedOnScroll(
              key: const ValueKey('exp_heading'),
              slideFrom: const Offset(-70, 0),
              child: Text(
                key: _experienceKey,
                'Experience',
                style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
              ),
            ),

            const SizedBox(height: 10),

            AnimatedOnScroll(
              key: const ValueKey('exp_section'),
              delay: const Duration(milliseconds: 200),
              slideFrom: const Offset(0, 50),
              child: ExperienceSection(),
            ),

            SizedBox(height: screenHeight * .15),

            AnimatedOnScroll(
              key: const ValueKey('edu_heading'),
              slideFrom: const Offset(-70, 0),
              child: Text(
                key: _educationKey,
                'Education',
                style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
              ),
            ),

            const SizedBox(height: 10),

            AnimatedOnScroll(
              key: const ValueKey('edu_section'),
              delay: const Duration(milliseconds: 200),
              slideFrom: const Offset(0, 50),
              child: EducationSection(),
            ),

            SizedBox(key: _contactKey, height: 60),

            AnimatedOnScroll(
              key: const ValueKey('contact_heading'),
              slideFrom: const Offset(0, 40),
              child: Text(
                'Reach out to me',
                style: textTheme.headlineLarge!.copyWith(
                  fontSize: roleFontSize,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 16),

            AnimatedOnScroll(
              key: const ValueKey('contact_body'),
              delay: const Duration(milliseconds: 150),
              slideFrom: const Offset(0, 35),
              child: Text(
                "I am open to new career opportunities, freelance collaborations, and remote roles worldwide.\n"
                "Let's build something great together—reach out to me.",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 12),

            AnimatedOnScroll(
              key: const ValueKey('contact_email'),
              delay: const Duration(milliseconds: 250),
              slideFrom: const Offset(0, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mohanmanu086@gmail.com',
                    style: textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 8921358229',
                    style: textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AnimatedOnScroll(
              key: const ValueKey('contact_social'),
              delay: const Duration(milliseconds: 350),
              slideFrom: const Offset(0, 25),
              child: _buildSocialRow(),
            ),

            const SizedBox(height: 50),

            AnimatedOnScroll(
              key: const ValueKey('footer'),
              delay: const Duration(milliseconds: 100),
              slideFrom: const Offset(0, 20),
              child: Center(
                child: Text(
                  'Made with ❤️ by Rayar Mohan',
                  style: textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CleanGridBackground(
        child: scrollContent,
      ),
    );
  }
}