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

class HomeScreen extends StatefulWidget {
  final ui.FragmentShader shader;
  const HomeScreen({super.key, required this.shader});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  // One GlobalKey per section
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isLarge = screenWidth >= 1100;
    final bool isMedium = screenWidth >= 700 && screenWidth < 1100;
    final bool isSmall = screenWidth < 700;
    final double nameFontSize = isLarge ? 90 : isMedium ? 60 : 40;
    final double roleFontSize = isLarge ? 60 : isMedium ? 40 : 28;
    final double horizontalPad = isLarge ? 50 : isMedium ? 30 : 16;
    final double lottieSize = isLarge ? 650 : isMedium ? 420 : 280;
    final double lottieOffset = isLarge ? -150 : isMedium ? -80 : 0;
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
                  // ── Navbar ──
                  isSmall
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("", style: textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                HoverShiningNavButton(
                                  text: 'Skills',
                                  onTap: () => _scrollToKey(_skillsKey),
                                ),
                                HoverShiningNavButton(
                                  text: 'Work Experience',
                                  onTap: () => _scrollToKey(_experienceKey),
                                ),
                                HoverShiningNavButton(
                                  text: 'Education',
                                  onTap: () => _scrollToKey(_educationKey),
                                ),
                                HoverShiningNavButton(
                                  text: 'Contact me',
                                  onTap: () => _scrollToKey(_contactKey),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Row(children: [Text("")]),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  HoverShiningNavButton(
                                    text: 'Skills',
                                    onTap: () => _scrollToKey(_skillsKey),
                                  ),
                                  HoverShiningNavButton(
                                    text: 'Work Experience',
                                    onTap: () => _scrollToKey(_experienceKey),
                                  ),
                                  HoverShiningNavButton(
                                    text: 'Education',
                                    onTap: () => _scrollToKey(_educationKey),
                                  ),
                                  HoverShiningNavButton(
                                    text: 'Contact me',
                                    onTap: () => _scrollToKey(_contactKey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 100),

                  // ── Hero section ──
                  isSmall
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: SizedBox(
                                width: lottieSize,
                                height: lottieSize,
                                child: _buildLottie(),
                              ),
                            ),
                            _buildTextBlock(
                              context,
                              textTheme,
                              nameFontSize,
                              roleFontSize,
                              screenWidth,
                            ),
                          ],
                        )
                      : Row(
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
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, lottieOffset),
                              child: SizedBox(
                                width: lottieSize,
                                height: lottieSize,
                                child: _buildLottie(),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(height: screenHeight * 0.15),

                  // ── Skills / What I Do section ── anchor here
                  isSmall
                      ? Column(
                          key: _skillsKey,            // ← anchor
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWhatIDoTextBlock(
                              context,
                              textTheme,
                              nameFontSize,
                              roleFontSize,
                              screenWidth,
                            ),
                            Center(
                              child: SizedBox(
                                width: lottieSize,
                                height: lottieSize,
                                child: _buildLottieRadio(),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: _skillsKey,            // ← anchor
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset: Offset(0, lottie2Offset),
                              child: SizedBox(
                                width: lottieSize,
                                height: lottieSize,
                                child: _buildLottieRadio(),
                              ),
                            ),
                            Expanded(
                              child: _buildWhatIDoTextBlock(
                                context,
                                textTheme,
                                nameFontSize,
                                roleFontSize,
                                screenWidth,
                              ),
                            ),
                          ],
                        ),

                  SizedBox(height: screenHeight * .20),

                  // ── Experience section ── anchor here
                  Text(
                    key: _experienceKey,              // ← anchor
                    'Experience',
                    style: textTheme.headlineLarge!
                        .copyWith(fontSize: nameFontSize),
                  ),
                  const SizedBox(height: 10),
                  ExperienceSection(),

                  SizedBox(height: screenHeight * .15),

                  // ── Education section ── anchor here
                  Text(
                    key: _educationKey,               // ← anchor
                    'Education',
                    style: textTheme.headlineLarge!
                        .copyWith(fontSize: nameFontSize),
                  ),
                  const SizedBox(height: 10),
                  EducationSection(),

                  // ── Contact section ── anchor here
                  SizedBox(key: _contactKey, height: 0), // ← invisible anchor
                  Text(
                    'Reach out to me',
                    style: textTheme.headlineLarge!.copyWith(
                      fontSize: roleFontSize,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "I am open to new career opportunities, freelance collaborations, and remote roles worldwide.\n"
                    "Let's build something great together—reach out to me.",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'mohanmanu086@gmail.com',
                    style: textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                  Text(
                    '+91 8921358229',
                    style: textTheme.titleMedium!.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => launchURL('https://github.com/Rayarmohan'),
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              AssetImage('assets/github_logo.png'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () =>
                            launchURL('mailto:mohanmanu0862@gmail.com'),
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/gmail_logo.jpg'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () =>
                            launchURL('https://in.linkedin.com/in/rayarmohan'),
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              AssetImage('assets/linkedin_logo.png'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => launchURL('https://wa.me/918921358229'),
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/whatsapp.png'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      'Made with ❤️ by Rayar Mohan',
                      style: textTheme.titleMedium!
                          .copyWith(color: Colors.grey),
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
        Text(
          'Rayar Mohan',
          style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
        ),
        const SizedBox(height: 20),
        Text(
          'Mobile App Developer',
          style: textTheme.headlineLarge!
              .copyWith(fontSize: roleFontSize, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          'Mobile App Developer skilled in crafting efficient Flutter applications for Android and iOS. '
          'Proficient in designing and developing scalable, high-performance mobile solutions with clean architecture. '
          'Strong foundation in state management, REST APIs, payment integrations, and real-time features. '
          'Eager collaborator committed to delivering high-quality products in fast-paced, team-oriented environments.',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 50),
        Row(
          children: [
            InkWell(
              onTap: () => launchURL('https://github.com/Rayarmohan'),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/github_logo.png'),
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () => launchURL('mailto:mohanmanu0862@gmail.com'),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/gmail_logo.jpg'),
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () =>
                  launchURL('https://in.linkedin.com/in/rayarmohan'),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/linkedin_logo.png'),
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () => launchURL('https://wa.me/918921358229'),
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/whatsapp.png'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ShiningButton(
              text: 'Download My RESUME',
              onTap: () async {
                const String assetPath = 'assets/RAYAR MOHAN.pdf';
                final Uri url = Uri.parse(assetPath);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $assetPath');
                }
              },
            ),
          ],
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
        Text(
          'What I Do',
          style: textTheme.headlineLarge!.copyWith(fontSize: nameFontSize),
        ),
        const SizedBox(height: 20),
        WhatIDoSection(),
        const SizedBox(height: 50),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: const [
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('flutter.jpg')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('android.jpg')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('ios.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('dart.jpg')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('firebase.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('cloudg.jpeg')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('git.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('postman.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('figma.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('aws.png')),
            CircleAvatar(radius: 30, backgroundColor: Colors.transparent, backgroundImage: AssetImage('stripe.png')),
          ],
        ),
      ],
    );
  }

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
}