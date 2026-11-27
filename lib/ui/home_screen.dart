import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rayar_mohan/core/helper_functions.dart';
import 'package:rayar_mohan/ui/widgets/education_section.dart';
import 'package:rayar_mohan/ui/widgets/experience_section.dart';
import 'package:rayar_mohan/ui/widgets/home_shining_nav_buttons.dart';
import 'package:rayar_mohan/ui/widgets/pointer_aura_background.dart';
import 'package:rayar_mohan/ui/widgets/profile_card.dart';
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
    _CodeLine(2, [_CodeSegment(');', _punc)]),
    _CodeLine(1, [_CodeSegment('}', _punc)]),
    _CodeLine(0, [_CodeSegment('}', _punc)]),
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
    _orb(
      canvas,
      c1,
      size.width * 0.30,
      const Color(0xFF2E43FF).withValues(alpha: 0.22),
    );
    _orb(
      canvas,
      c2,
      size.width * 0.28,
      const Color(0xFF9A5BFF).withValues(alpha: 0.18),
    );
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
    final rrect = RRect.fromRectAndRadius(card, Radius.circular(cardW * 0.045));

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

    const dotColors = [Color(0xFFFF5F57), Color(0xFFFFBD2E), Color(0xFF28C840)];
    double x = card.left + cardW * 0.045;
    for (final c in dotColors) {
      canvas.drawCircle(
        Offset(x, y),
        dotR,
        Paint()..color = c.withValues(alpha: 0.9),
      );
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
    final double lineHeight = math.min(fontPx * 1.55, available / _code.length);
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
        Offset(
          gutterRight - numberTp.width,
          y + (fontPx - numberTp.height) * 0.5,
        ),
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
          Rect.fromLTWH(
            card.left + cardW * 0.035,
            indicatorY,
            fontPx * 0.22,
            lineHeight * 0.8,
          ),
          Radius.circular(fontPx * 0.12),
        ),
        Paint()..color = const Color(0xFF4FD1C5).withValues(alpha: 0.8),
      );

      final double blink = (math.sin(t * 2 * math.pi * 8) + 1) / 2;
      final double caretOpacity = blink > 0.5 ? 0.95 : 0.15;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            caretX + 1,
            caretY,
            math.max(1.8, fontPx * 0.11),
            fontPx * 1.15,
          ),
          const Radius.circular(1),
        ),
        Paint()
          ..color = const Color(0xFFA9D606).withValues(alpha: caretOpacity),
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
      Offset(dotX, centerY),
      dotR,
      Paint()..color = const Color(0xFF28C840),
    );

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
      Offset(
        card.right - rightTp.width - cardW * 0.045,
        centerY - rightTp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CodeEditorPainter oldDelegate) => true;
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

  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _educationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

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
        _socialAvatar(
          'assets/github_logo.png',
          'https://github.com/Rayarmohan',
        ),
        const SizedBox(width: 20),
        _socialAvatar(
          'assets/gmail_logo.jpg',
          'mailto:mohanmanu0862@gmail.com',
        ),
        const SizedBox(width: 20),
        _socialAvatar(
          'assets/linkedin_logo.png',
          'https://in.linkedin.com/in/rayarmohan',
        ),
        const SizedBox(width: 20),
        _socialAvatar('assets/whatsapp.png', 'https://wa.me/918921358229'),
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

  Widget _buildProfileCard(double width) {
    return ProfileCard(
      avatarUrl: 'assets/pro_pic.png',
      miniAvatarUrl: 'assets/pro_pic.png',
      name: 'Rayar Mohan',
      title: 'Mobile App Developer',
      handle: 'rayarmohan',
      status: 'Available for work',
      contactText: 'Contact Me',
      width: width,
      onContactClick: () => _scrollToKey(_contactKey),
    );
  }

  List<Widget> _navButtons({bool compact = false}) {
    return [
      HoverShiningNavButton(
        text: 'Skills',
        compact: compact,
        onTap: () => _scrollToKey(_skillsKey),
      ),
      HoverShiningNavButton(
        text: compact ? 'Experience' : 'Work Experience',
        compact: compact,
        onTap: () => _scrollToKey(_experienceKey),
      ),
      HoverShiningNavButton(
        text: 'Education',
        compact: compact,
        onTap: () => _scrollToKey(_educationKey),
      ),
      HoverShiningNavButton(
        text: compact ? 'Contact' : 'Contact me',
        compact: compact,
        onTap: () => _scrollToKey(_contactKey),
      ),
    ];
  }

  Widget _buildNavbar(
    bool isSmall,
    bool isMedium,
    bool isLarge,
    TextTheme textTheme,
  ) {
    final List<Widget> navButtons = _navButtons(compact: isSmall);

    if (isSmall) {
      return Wrap(spacing: 8, runSpacing: 8, children: navButtons);
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

  static const String _bioText =
      'Mobile App Developer skilled in crafting efficient Flutter applications for Android and iOS. '
      'Proficient in designing and developing scalable, high-performance mobile solutions with clean architecture. '
      'Strong foundation in state management, REST APIs, payment integrations, and real-time features. '
      'Eager collaborator committed to delivering high-quality products in fast-paced, team-oriented environments.';

  static const String _contactBlurb =
      "I am open to new career opportunities, freelance collaborations, and remote roles worldwide.\n"
      "Let's build something great together—reach out to me.";

  Widget _buildRole(TextTheme textTheme, double roleFontSize) {
    return AnimatedOnScroll(
      key: const ValueKey('hero_role'),
      delay: const Duration(milliseconds: 220),
      slideFrom: const Offset(0, 35),
      child: Text(
        'Mobile App Developer',
        style: textTheme.headlineLarge!.copyWith(
          fontSize: roleFontSize,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBio(TextTheme textTheme, {required bool isMobile}) {
    return AnimatedOnScroll(
      key: const ValueKey('hero_bio'),
      delay: const Duration(milliseconds: 340),
      slideFrom: const Offset(0, 30),
      child: Text(
        _bioText,
        style: isMobile
            ? textTheme.bodyLarge!.copyWith(
                fontSize: 15.5,
                height: 1.65,
                color: Colors.white.withValues(alpha: 0.82),
              )
            : textTheme.headlineMedium,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildSocialBlock() {
    return AnimatedOnScroll(
      key: const ValueKey('hero_social'),
      delay: const Duration(milliseconds: 460),
      slideFrom: const Offset(0, 25),
      child: _buildSocialRow(),
    );
  }

  Widget _buildResumeButton() {
    return AnimatedOnScroll(
      key: const ValueKey('hero_resume'),
      delay: const Duration(milliseconds: 560),
      slideFrom: const Offset(0, 20),
      child: Row(
        children: [
          ShiningButton(
            text: 'Download My RESUME',
            onTap: () async {
              final Uri url = Uri.parse(
                'https://rayarmohan.github.io/assets/assets/rayar_mohan.pdf',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                await launchUrl(
                  Uri.parse(
                    'https://rayarmohan.github.io/assets/rayar_mohan.pdf',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(
    TextTheme textTheme,
    double nameFontSize,
    double roleFontSize, {
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
        _buildRole(textTheme, roleFontSize),
        const SizedBox(height: 16),
        _buildBio(textTheme, isMobile: false),
        const SizedBox(height: 28),
        _buildSocialBlock(),
        const SizedBox(height: 20),
        _buildResumeButton(),
      ],
    );
  }

  Widget _buildMobileHero(
    TextTheme textTheme,
    double nameFontSize,
    double roleFontSize,
    double cardWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildName(textTheme, nameFontSize),
        const SizedBox(height: 8),
        _buildRole(textTheme, roleFontSize),
        const SizedBox(height: 28),
        AnimatedOnScroll(
          key: const ValueKey('hero_card_mobile'),
          slideFrom: const Offset(0, -30),
          duration: const Duration(milliseconds: 800),
          child: Center(child: _buildProfileCard(cardWidth)),
        ),
        const SizedBox(height: 28),
        _buildBio(textTheme, isMobile: true),
        const SizedBox(height: 22),
        _buildSocialBlock(),
        const SizedBox(height: 22),
        _buildResumeButton(),
      ],
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required TextTheme textTheme,
    required double fontSize,
    Key? key,
    Key? textKey,
    Offset slideFrom = const Offset(-70, 0),
  }) {
    return AnimatedOnScroll(
      key: key,
      slideFrom: slideFrom,
      child: Text(
        title,
        key: textKey,
        style: textTheme.headlineLarge!.copyWith(fontSize: fontSize),
      ),
    );
  }

  Widget _buildTechStack({required double radius, required bool isMobile}) {
    const List<String> assets = [
      'assets/flutter.jpg',
      'assets/android.jpg',
      'assets/ios.png',
      'assets/dart.jpg',
      'assets/firebase.png',
      'assets/cloudg.jpeg',
      'assets/git.png',
      'assets/postman.png',
      'assets/figma.png',
      'assets/aws.png',
      'assets/stripe.png',
    ];
    return Wrap(
      spacing: isMobile ? 16 : 20,
      runSpacing: isMobile ? 16 : 20,
      children: [
        for (final asset in assets)
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(asset),
          ),
      ],
    );
  }

  Widget _buildSkillsSection({
    required TextTheme textTheme,
    required bool isSmall,
    required double headingFontSize,
    required double visualSize,
    required double visualOffset,
  }) {
    const double mobileVisualSize = 240;
    final double techRadius = isSmall ? 24 : 30;

    final Widget heading = _buildSectionTitle(
      title: 'What I Do',
      textTheme: textTheme,
      fontSize: headingFontSize,
      key: const ValueKey('skills_heading'),
      slideFrom: const Offset(-60, 0),
    );

    final Widget services = AnimatedOnScroll(
      key: const ValueKey('skills_list'),
      delay: const Duration(milliseconds: 150),
      slideFrom: const Offset(0, 40),
      child: const WhatIDoSection(),
    );

    final Widget stack = AnimatedOnScroll(
      key: const ValueKey('skills_stack'),
      delay: const Duration(milliseconds: 300),
      slideFrom: const Offset(0, 30),
      child: _buildTechStack(radius: techRadius, isMobile: isSmall),
    );

    if (isSmall) {
      final Widget visual = AnimatedOnScroll(
        key: const ValueKey('skills_visual_mobile'),
        slideFrom: const Offset(0, 40),
        child: Center(
          child: SizedBox(
            width: mobileVisualSize,
            height: mobileVisualSize,
            child: const CodeEditorAnimation(),
          ),
        ),
      );
      return Column(
        key: _skillsKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          heading,
          const SizedBox(height: 24),
          visual,
          const SizedBox(height: 32),
          services,
          const SizedBox(height: 40),
          stack,
        ],
      );
    }

    return Row(
      key: _skillsKey,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedOnScroll(
          key: const ValueKey('skills_visual'),
          slideFrom: const Offset(-80, 0),
          duration: const Duration(milliseconds: 900),
          child: Transform.translate(
            offset: Offset(0, visualOffset),
            child: SizedBox(
              width: visualSize,
              height: visualSize,
              child: const CodeEditorAnimation(),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              heading,
              const SizedBox(height: 20),
              services,
              const SizedBox(height: 50),
              stack,
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isLarge = screenWidth >= 1100;
    final bool isMedium = screenWidth >= 700 && screenWidth < 1100;
    final bool isSmall = screenWidth < 700;

    final double heroNameSize = isLarge
        ? 90
        : isMedium
        ? 60
        : 34;
    final double headingFontSize = isLarge
        ? 90
        : isMedium
        ? 60
        : 30;
    final double roleFontSize = isLarge
        ? 60
        : isMedium
        ? 40
        : 21;
    final double horizontalPad = isLarge
        ? 50
        : isMedium
        ? 30
        : 18;
    final double lottieSize = isLarge
        ? 500
        : isMedium
        ? 360
        : 190;
    final double lottieOffset = isLarge
        ? 0
        : isMedium
        ? -20
        : 0;
    final double lottie2Offset = isLarge
        ? -24
        : isMedium
        ? -12
        : 0;
    final double profileCardWidth = isLarge
        ? 340
        : isMedium
        ? 300
        : (screenWidth - 110).clamp(240.0, 300.0);

    final double topPadding = isSmall ? 24 : 50;
    final double heroToSkillsGap = isSmall ? 64 : screenHeight * 0.15;
    final double skillsToExperienceGap = isSmall ? 72 : screenHeight * 0.20;
    final double sectionGap = isSmall ? 64 : screenHeight * 0.15;

    final scrollContent = SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPad,
          top: topPadding,
          right: horizontalPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSmall
                ? _buildMobileHero(
                    textTheme,
                    heroNameSize,
                    roleFontSize,
                    profileCardWidth,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildName(textTheme, heroNameSize),
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
                              textTheme,
                              heroNameSize,
                              roleFontSize,
                              showName: false,
                            ),
                          ),
                          SizedBox(width: isLarge ? 56 : 32),
                          AnimatedOnScroll(
                            key: const ValueKey('hero_lottie'),
                            slideFrom: const Offset(80, 0),
                            duration: const Duration(milliseconds: 900),
                            child: Transform.translate(
                              offset: Offset(0, lottieOffset),
                              child: _buildProfileCard(profileCardWidth),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

            SizedBox(height: heroToSkillsGap),

            _buildSkillsSection(
              textTheme: textTheme,
              isSmall: isSmall,
              headingFontSize: headingFontSize,
              visualSize: lottieSize,
              visualOffset: lottie2Offset,
            ),

            SizedBox(height: skillsToExperienceGap),

            _buildSectionTitle(
              title: 'Experience',
              textTheme: textTheme,
              fontSize: headingFontSize,
              key: const ValueKey('exp_heading'),
              textKey: _experienceKey,
            ),

            const SizedBox(height: 10),

            AnimatedOnScroll(
              key: const ValueKey('exp_section'),
              delay: const Duration(milliseconds: 200),
              slideFrom: const Offset(0, 50),
              child: ExperienceSection(),
            ),

            SizedBox(height: sectionGap),

            _buildSectionTitle(
              title: 'Education',
              textTheme: textTheme,
              fontSize: headingFontSize,
              key: const ValueKey('edu_heading'),
              textKey: _educationKey,
            ),

            const SizedBox(height: 10),

            AnimatedOnScroll(
              key: const ValueKey('edu_section'),
              delay: const Duration(milliseconds: 200),
              slideFrom: const Offset(0, 50),
              child: EducationSection(),
            ),

            SizedBox(key: _contactKey, height: isSmall ? 44 : 60),

            AnimatedOnScroll(
              key: const ValueKey('contact_heading'),
              slideFrom: const Offset(0, 40),
              child: Text(
                'Reach out to me',
                style: textTheme.headlineLarge!.copyWith(
                  fontSize: isSmall ? 28 : roleFontSize,
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
                _contactBlurb,
                style: isSmall
                    ? textTheme.bodyLarge!.copyWith(
                        fontSize: 15.5,
                        height: 1.65,
                        color: Colors.white.withValues(alpha: 0.82),
                      )
                    : textTheme.headlineMedium,
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
                    style: textTheme.titleMedium!.copyWith(
                      color: Colors.grey,
                      fontSize: isSmall ? 15 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 8921358229',
                    style: textTheme.titleMedium!.copyWith(
                      color: Colors.grey,
                      fontSize: isSmall ? 15 : null,
                    ),
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
                  style: textTheme.titleMedium!.copyWith(
                    color: Colors.grey,
                    fontSize: isSmall ? 15 : null,
                  ),
                ),
              ),
            ),

            SizedBox(height: isSmall ? 56 : 100),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: isSmall
          ? SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xF20B0D12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _mobileNavItem(
                      Icons.auto_awesome_outlined,
                      'Skills',
                      () => _scrollToKey(_skillsKey),
                    ),
                    _mobileNavItem(
                      Icons.work_outline_rounded,
                      'Work',
                      () => _scrollToKey(_experienceKey),
                    ),
                    _mobileNavItem(
                      Icons.school_outlined,
                      'Education',
                      () => _scrollToKey(_educationKey),
                    ),
                    _mobileNavItem(
                      Icons.mail_outline_rounded,
                      'Contact',
                      () => _scrollToKey(_contactKey),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: CleanGridBackground(
        child: SafeArea(top: false, bottom: false, child: scrollContent),
      ),
    );
  }

  Widget _mobileNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: const Color(0xFFA9D606)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
