import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollBy(double direction) {
    if (!_controller.hasClients) return;
    final double target = (_controller.offset + direction * 460).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  static const List<_ExperienceData> _workHistory = [
    _ExperienceData(
      company: 'Logiology Solutions',
      role: 'Software Engineer',
      duration: 'Aug 2026 – Present',
      topColor: Color(0xFF14B8A6),
      logoText: 'Lg',
      bullets: [
        'Architected a white-label Flutter system (flavors) driving 30+ client apps from one codebase.',
        'Shipped Jewellery Customer and Sales Officer apps to the App Store and Play Store.',
        'Integrated 8+ payment gateways (Razorpay, PhonePe, Paytm, Cashfree, PayU and more).',
        'Implemented BLoC/GetX state management, resilient REST APIs and offline support.',
        'Secured tokens and credentials with Flutter Secure Storage and QR-based onboarding.',
      ],
      tags: ['Flutter', 'Dart', 'BLoC', 'GetX', 'Payments'],
    ),
    _ExperienceData(
      company: 'iCodeBees Pvt Ltd.',
      role: 'Software Developer',
      duration: 'June 2024 – June 2026',
      topColor: Color(0xFF3B82F6),
      logoText: 'iB',
      bullets: [
        'Designed, built and debugged production-ready Flutter apps for Android and iOS.',
        'Integrated Stripe and Cashfree payments along with Google Maps SDK.',
        'Applied GetX/BLoC state management and Clean Architecture patterns.',
        'Built e-commerce features and checkout flows for real users.',
        'Published and maintained releases on the Play Store and App Store.',
      ],
      tags: ['Flutter', 'GetX', 'Stripe', 'Maps'],
    ),
    _ExperienceData(
      company: 'Acube Innovations',
      role: 'Software Developer',
      duration: 'Dec 2023 – Apr 2024',
      topColor: Color(0xFF8B5CF6),
      logoText: 'Ac',
      bullets: [
        'Built the A3Sola salesperson app with Hive caching and ERPNext backend.',
        'Developed the Jambo Taxi driver app with real-time trip features.',
        'Integrated REST APIs via Dio in close collaboration with the backend team.',
        'Worked in Agile sprints with code reviews and release planning.',
      ],
      tags: ['Flutter', 'Hive', 'Dio', 'ERPNext'],
    ),
    _ExperienceData(
      company: 'Weberfox Technologies',
      role: 'Flutter Developer Intern',
      duration: 'May 2023 – July 2023',
      topColor: Color(0xFFEF5350),
      logoText: 'Wf',
      bullets: [
        'Turned design mockups into responsive, reusable Flutter UI components.',
        'Built Flutter apps using GetX, BLoC and Firebase backend tools.',
        'Strengthened understanding of widget lifecycles and state management.',
        'Collaborated with mentors to ship polished, testable screens.',
      ],
      tags: ['Flutter', 'Firebase', 'GetX', 'BLoC'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    if (isMobile) {
      final double cardWidth = (screenWidth * 0.84).clamp(270.0, 360.0);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Swipe to explore',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.swipe_rounded, size: 16, color: Colors.grey[500]),
                ],
              ),
            ),
            SizedBox(
              height: 620,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                  scrollbars: false,
                ),
                child: ListView.separated(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(2, 4, 12, 14),
                  itemCount: _workHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => SizedBox(
                    width: cardWidth,
                    child: _ExperienceCard(
                      data: _workHistory[index],
                      fillHeight: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isDesktop = screenWidth > 1000;
    final double cardWidth = isDesktop
        ? 430
        : (screenWidth * 0.86).clamp(280.0, 430.0);
    final double cardHeight = isDesktop ? 460 : 540;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Scroll to explore',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              _arrowButton(
                Icons.arrow_back_ios_new_rounded,
                () => _scrollBy(-1),
              ),
              const SizedBox(width: 8),
              _arrowButton(Icons.arrow_forward_ios_rounded, () => _scrollBy(1)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: cardHeight + 24,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
                scrollbars: false,
              ),
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 2,
                ),
                itemCount: _workHistory.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: cardWidth,
                    child: _ExperienceCard(data: _workHistory[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, size: 14, color: Colors.white70),
        ),
      ),
    );
  }
}

class _ExperienceData {
  final String company;
  final String role;
  final String duration;
  final Color topColor;
  final String logoText;
  final List<String> bullets;
  final List<String> tags;

  const _ExperienceData({
    required this.company,
    required this.role,
    required this.duration,
    required this.topColor,
    required this.logoText,
    required this.bullets,
    required this.tags,
  });
}

class _ExperienceCard extends StatefulWidget {
  final _ExperienceData data;
  final bool fillHeight;

  const _ExperienceCard({required this.data, this.fillHeight = true});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final _ExperienceData data = widget.data;
    final Color accent = Color.lerp(data.topColor, Colors.white, 0.55)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101010), Color(0xFF070707)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? data.topColor.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.08),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: data.topColor.withValues(alpha: 0.28),
                    blurRadius: 26,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.topColor,
                      data.topColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              if (widget.fillHeight)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(accent),
                        const SizedBox(height: 16),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.08),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: data.bullets
                                .map((bullet) => _bullet(bullet, accent))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _tags(),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _header(accent),
                      const SizedBox(height: 14),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 1,
                      ),
                      const SizedBox(height: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: data.bullets
                            .map((bullet) => _bullet(bullet, accent))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      _tags(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Color accent) {
    final _ExperienceData data = widget.data;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _logoBadge(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.company,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.role,
                style: TextStyle(
                  color: accent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      data.duration,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logoBadge() {
    final _ExperienceData data = widget.data;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.topColor.withValues(alpha: 0.95),
            data.topColor.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: data.topColor.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          data.logoText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: widget.data.topColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.check_rounded, size: 12, color: accent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.data.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: widget.data.topColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.data.topColor.withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }
}
