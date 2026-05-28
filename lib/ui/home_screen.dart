import 'dart:ui' as ui;

import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:gradient_mouse/core/helper_functions.dart';
import 'package:gradient_mouse/ui/widgets/education_section.dart';
import 'package:gradient_mouse/ui/widgets/experience_section.dart';
import 'package:gradient_mouse/ui/widgets/gradient_blinds.dart';
import 'package:gradient_mouse/ui/widgets/home_shining_nav_buttons.dart';
import 'package:gradient_mouse/ui/widgets/shining_button.dart';
import 'package:gradient_mouse/ui/widgets/what_i_do.dart';
import 'package:lottie/lottie.dart';
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

  // ── Social icon row (reused in hero + contact) ──────────────
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

  // ── Lottie builders ─────────────────────────────────────────
  Widget _buildLottie() {
    return DotLottieLoader.fromAsset(
      'assets/spaceboydeveloper.lottie',
      frameBuilder: (BuildContext context, DotLottie? lottie) {
        if (lottie != null) {
          return Lottie.memory(
            alignment: Alignment.topCenter,
            lottie.animations.values.single,
            fit: BoxFit.contain,
          );
        }
        return const Center(child: CircularProgressIndicator(color: Colors.grey));
      },
    );
  }

  Widget _buildLottieRadio() {
    return DotLottieLoader.fromAsset(
      'assets/radio.lottie',
      frameBuilder: (BuildContext context, DotLottie? lottie) {
        if (lottie != null) {
          return Lottie.memory(
            alignment: Alignment.topCenter,
            lottie.animations.values.single,
            fit: BoxFit.contain,
          );
        }
        return const Center(child: CircularProgressIndicator(color: Colors.grey));
      },
    );
  }

  // ── Navbar ──────────────────────────────────────────────────
  Widget _buildNavbar(
    bool isSmall,
    bool isMedium,
    bool isLarge,
    TextTheme textTheme,
  ) {
    // The 4 nav buttons — shared across all layouts
    final List<Widget> navButtons = [
      HoverShiningNavButton(text: 'Skills',          onTap: () => _scrollToKey(_skillsKey)),
      HoverShiningNavButton(text: 'Work Experience', onTap: () => _scrollToKey(_experienceKey)),
      HoverShiningNavButton(text: 'Education',       onTap: () => _scrollToKey(_educationKey)),
      HoverShiningNavButton(text: 'Contact me',      onTap: () => _scrollToKey(_contactKey)),
    ];

    // ── Small: stack name above wrapped buttons ──────────────
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

    // ── Medium: single row, evenly spaced, no overflow ───────
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

    // ── Large: name on left, buttons on right ─────────────────
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left spacer (empty — logo/name could go here later)
        const Spacer(flex: 2),

        // Right side: buttons that NEVER overflow
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

  // ── Hero text block ─────────────────────────────────────────
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

        // Name
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

        // Role
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

        // Bio
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

        // Social icons
        AnimatedOnScroll(
          key: const ValueKey('hero_social'),
          delay: const Duration(milliseconds: 460),
          slideFrom: const Offset(0, 25),
          child: _buildSocialRow(),
        ),

        const SizedBox(height: 20),

        // Resume button
        AnimatedOnScroll(
          key: const ValueKey('hero_resume'),
          delay: const Duration(milliseconds: 560),
          slideFrom: const Offset(0, 20),
          child: Row(
            children: [
              ShiningButton(
                text: 'Download My RESUME',
                onTap: () async {
                  // On web, assets are served from the root URL
                  final Uri url = Uri.parse('assets/RAYAR MOHAN.pdf');
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    // Fallback: try opening directly
                    await launchUrl(
                      Uri.parse('https://rayarmohan.github.io/assets/RAYAR%20MOHAN.pdf'),
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

  // ── What I Do text block ────────────────────────────────────
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

        // Heading
        AnimatedOnScroll(
          key: const ValueKey('skills_heading'),
          slideFrom: const Offset(-60, 0),
          child: Text(
            'What I Do',
            style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
          ),
        ),

        const SizedBox(height: 20),

        // WhatIDoSection list
        AnimatedOnScroll(
          key: const ValueKey('skills_list'),
          delay: const Duration(milliseconds: 150),
          slideFrom: const Offset(0, 40),
          child: WhatIDoSection(),
        ),

        const SizedBox(height: 50),

        // Tech stack icons
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

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
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
            // ── Background shader ──────────────────────────────
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

                  // ── Navbar ───────────────────────────────────
                  AnimatedOnScroll(
                    key: const ValueKey('navbar'),
                    slideFrom: const Offset(0, -30),
                    duration: const Duration(milliseconds: 500),
                    child: _buildNavbar(isSmall, isMedium, isLarge, textTheme),
                  ),

                  const SizedBox(height: 100),

                  // ── Hero section ─────────────────────────────
                  isSmall
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lottie fades in from above on small screens
                            AnimatedOnScroll(
                              key: const ValueKey('hero_lottie_small'),
                              slideFrom: const Offset(0, -40),
                              duration: const Duration(milliseconds: 800),
                              child: Center(
                                child: SizedBox(
                                  width: lottieSize,
                                  height: lottieSize,
                                  child: _buildLottie(),
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
                            // Lottie slides in from the right
                            AnimatedOnScroll(
                              key: const ValueKey('hero_lottie'),
                              slideFrom: const Offset(80, 0),
                              duration: const Duration(milliseconds: 900),
                              child: Transform.translate(
                                offset: Offset(0, lottieOffset),
                                child: SizedBox(
                                  width: lottieSize,
                                  height: lottieSize,
                                  child: _buildLottie(),
                                ),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(height: screenHeight * 0.15),

                  // ── Skills / What I Do section ───────────────
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
                                  child: _buildLottieRadio(),
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
                            // Radio lottie slides in from the left
                            AnimatedOnScroll(
                              key: const ValueKey('skills_lottie'),
                              slideFrom: const Offset(-80, 0),
                              duration: const Duration(milliseconds: 900),
                              child: Transform.translate(
                                offset: Offset(0, lottie2Offset),
                                child: SizedBox(
                                  width: lottieSize,
                                  height: lottieSize,
                                  child: _buildLottieRadio(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildWhatIDoTextBlock(context, textTheme, nameFontSize, roleFontSize, screenWidth),
                            ),
                          ],
                        ),

                  SizedBox(height: screenHeight * .20),

                  // ── Experience section ───────────────────────
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

                  // ── Education section ────────────────────────
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

                  // ── Contact section ──────────────────────────
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

                  // ── Footer ───────────────────────────────────
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