import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gradient_mouse/core/helper_functions.dart';
import 'package:gradient_mouse/ui/widgets/education_section.dart';
import 'package:gradient_mouse/ui/widgets/experience_section.dart';
import 'package:gradient_mouse/ui/widgets/gradient_blinds.dart';
import 'package:gradient_mouse/ui/widgets/home_shining_nav_buttons.dart';
import 'package:gradient_mouse/ui/widgets/shining_button.dart';
import 'package:gradient_mouse/ui/widgets/what_i_do.dart';
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
// CosmicAstronautAnimation  –  canvas-drawn floating astronaut
// ─────────────────────────────────────────────────────────────
class CosmicAstronautAnimation extends StatefulWidget {
  const CosmicAstronautAnimation({super.key});

  @override
  State<CosmicAstronautAnimation> createState() => _CosmicAstronautAnimationState();
}

class _CosmicAstronautAnimationState extends State<CosmicAstronautAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Star> _stars = List.generate(45, (_) => _Star.random());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
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
          painter: _AstronautPainter(_controller.value, _stars),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double speed;

  _Star(this.dx, this.dy, this.radius, this.speed);

  factory _Star.random() {
    final rnd = math.Random();
    return _Star(
      rnd.nextDouble(),
      rnd.nextDouble(),
      rnd.nextDouble() * 1.6 + 0.6,
      rnd.nextDouble() * 2 + 0.5,
    );
  }
}

class _AstronautPainter extends CustomPainter {
  final double t;
  final List<_Star> stars;

  _AstronautPainter(this.t, this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final star in stars) {
      final twinkle = (math.sin(t * 2 * math.pi * star.speed) + 1) / 2;
      final paint = Paint()..color = Colors.white.withOpacity(0.2 + twinkle * 0.6);
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), star.radius, paint);
    }

    final bob = math.sin(t * 2 * math.pi) * size.height * 0.03;
    final astronautCenter = Offset(center.dx, center.dy + bob);

    final glowPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(astronautCenter, size.width * 0.28, glowPaint);

    _drawOrbitDust(canvas, astronautCenter, size);
    _drawAstronaut(canvas, astronautCenter, size);
  }

  void _drawOrbitDust(Canvas canvas, Offset center, Size size) {
    final orbitRadius = size.width * 0.32;
    final angle = t * 2 * math.pi;

    final trailPaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = Rect.fromCenter(center: center, width: orbitRadius * 2, height: orbitRadius * 0.8);
    canvas.drawOval(rect, trailPaint);

    final dustPos = Offset(
      center.dx + orbitRadius * math.cos(angle),
      center.dy + orbitRadius * 0.4 * math.sin(angle),
    );
    canvas.drawCircle(dustPos, 5, Paint()..color = Colors.purpleAccent.withOpacity(0.85));

    final secondAngle = angle * 1.6 + math.pi;
    final secondPos = Offset(
      center.dx + orbitRadius * 0.7 * math.cos(secondAngle),
      center.dy + orbitRadius * 0.55 * math.sin(secondAngle),
    );
    canvas.drawCircle(secondPos, 3.5, Paint()..color = Colors.cyanAccent.withOpacity(0.85));
  }

  void _drawAstronaut(Canvas canvas, Offset center, Size size) {
    final scale = size.width / 280;
    final bodyPaint = Paint()..color = const Color(0xFFE8E8E8);
    final shadingStroke = Paint()
      ..color = const Color(0xFFB8C4D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;
    final visorPaint = Paint()..color = const Color(0xFF203A55);
    final visorHighlight = Paint()..color = Colors.white.withOpacity(0.5);
    final tiltAngle = math.sin(t * 2 * math.pi) * 0.05;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, 40 * scale), width: 90 * scale, height: 110 * scale),
      Radius.circular(40 * scale),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, shadingStroke);

    final leftArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-55 * scale, 30 * scale), width: 30 * scale, height: 60 * scale),
      Radius.circular(15 * scale),
    );
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(55 * scale, 10 * scale), width: 30 * scale, height: 60 * scale),
      Radius.circular(15 * scale),
    );
    canvas.drawRRect(leftArm, bodyPaint);
    canvas.drawRRect(rightArm, bodyPaint);

    canvas.drawCircle(Offset(0, -30 * scale), 55 * scale, bodyPaint);
    canvas.drawCircle(
      Offset(0, -30 * scale),
      55 * scale,
      Paint()
        ..color = const Color(0xFFB8C4D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * scale,
    );

    canvas.drawCircle(Offset(5 * scale, -32 * scale), 38 * scale, visorPaint);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(-5 * scale, -45 * scale), width: 30 * scale, height: 20 * scale),
      math.pi * 0.9,
      math.pi * 0.6,
      false,
      visorHighlight,
    );

    final chestLightOpacity = 0.8 + math.sin(t * 2 * math.pi * 3) * 0.2;
    canvas.drawCircle(
      Offset(0, 30 * scale),
      6 * scale,
      Paint()..color = Colors.redAccent.withOpacity(chestLightOpacity),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AstronautPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────
// AtomOrbitAnimation  –  canvas-drawn orbiting electrons
// ─────────────────────────────────────────────────────────────
class AtomOrbitAnimation extends StatefulWidget {
  const AtomOrbitAnimation({super.key});

  @override
  State<AtomOrbitAnimation> createState() => _AtomOrbitAnimationState();
}

class _AtomOrbitAnimationState extends State<AtomOrbitAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
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
          painter: _AtomPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AtomPainter extends CustomPainter {
  final double t;

  _AtomPainter(this.t);

  static const List<double> _orbitTilts = [0.0, math.pi / 3, -math.pi / 3];
  static const List<double> _orbitSpeeds = [1.0, 1.4, 0.7];
  static const List<Color> _orbitColors = [Colors.cyanAccent, Colors.purpleAccent, Colors.greenAccent];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;

    final nucleusGlow = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, size.width * 0.12, nucleusGlow);
    canvas.drawCircle(center, size.width * 0.045, Paint()..color = const Color(0xFFFFC168));

    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(_orbitTilts[i]);

      final orbitPaint = Paint()
        ..color = _orbitColors[i].withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 0.7),
        orbitPaint,
      );

      final angle = t * 2 * math.pi * _orbitSpeeds[i];
      final electronPos = Offset(radius * math.cos(angle), radius * 0.35 * math.sin(angle));

      canvas.drawCircle(
        electronPos,
        9,
        Paint()
          ..color = _orbitColors[i].withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(electronPos, 5, Paint()..color = _orbitColors[i]);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _AtomPainter oldDelegate) => true;
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

  Widget _buildNavbar(
    bool isSmall,
    bool isMedium,
    bool isLarge,
    TextTheme textTheme,
  ) {
    final List<Widget> navButtons = [
      HoverShiningNavButton(text: 'Skills',          onTap: () => _scrollToKey(_skillsKey)),
      HoverShiningNavButton(text: 'Work Experience', onTap: () => _scrollToKey(_experienceKey)),
      HoverShiningNavButton(text: 'Education',       onTap: () => _scrollToKey(_educationKey)),
      HoverShiningNavButton(text: 'Contact me',      onTap: () => _scrollToKey(_contactKey)),
    ];

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

  Widget _buildTextBlock(
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
          key: const ValueKey('hero_name'),
          delay: const Duration(milliseconds: 100),
          slideFrom: const Offset(0, 40),
          child: Text(
            'Rayar Mohan',
            style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
          ),
        ),

        const SizedBox(height: 20),

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

        const SizedBox(height: 50),

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
    final double lottieSize    = isLarge ? 650 : isMedium ? 420 : 280;
    final double lottieOffset  = isLarge ? -150 : isMedium ? -80 : 0;
    final double lottie2Offset = isLarge ? 60 : isMedium ? 10 : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            Positioned.fill(
              child: GradientBlinds(
                shader: widget.shader,
                angle: 45,
                blindCount: 20,
                gradientColors: const [
                  ui.Color.fromARGB(255, 101, 128, 3),
                  ui.Color.fromARGB(255, 6, 20, 141),
                  ui.Color.fromARGB(255, 7, 145, 18),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                left: horizontalPad,
                top: 50,
                right: horizontalPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  AnimatedOnScroll(
                    key: const ValueKey('navbar'),
                    slideFrom: const Offset(0, -30),
                    duration: const Duration(milliseconds: 500),
                    child: _buildNavbar(isSmall, isMedium, isLarge, textTheme),
                  ),

                  const SizedBox(height: 100),

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
                                  child: const CosmicAstronautAnimation(),
                                ),
                              ),
                            ),
                            _buildTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
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
                                  child: const CosmicAstronautAnimation(),
                                ),
                              ),
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
                                  child: const AtomOrbitAnimation(),
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
                                  child: const AtomOrbitAnimation(),
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
          ],
        ),
      ),
    );
  }
}