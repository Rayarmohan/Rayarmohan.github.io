import 'package:flutter/material.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1000;

    final workHistory = [
      _ExperienceData(
        company: 'Logiology Solutions',
        role: 'Software Engineer',
        duration: 'Aug 2026 – Present',
        topColor: const Color(0xFF00897B),
        logoText: 'Lg',
        bullets: [
          'Developed and maintained Jewellery Customer apps and a Sales Officer app in Flutter for iOS and Android, shipping regular updates to the App Store and Play Store.',
          'Built a white-label architecture using Flutter flavors, managing 30+ client-specific customer apps from a single codebase with per-client branding, UI, and configuration through flavor constants.',
          'Integrated 8+ payment gateways, including Razorpay, Easebuzz, PhonePe, Paytm, HDFC SmartGateway, Cashfree, Omniware, and PayU, with each client\'s app connected to its own gateway through flavor-based configuration.',
          'Implemented state management with BLoC and GetX, and built scalable API integration with robust error handling.',
          'Designed offline support so the apps stay usable with poor connectivity, and used Flutter Secure Storage to protect sensitive data such as login credentials and tokens.',
          'Built the Sales Officer app with a QR-scan onboarding flow: scanning a QR code determines which client database to connect to, fetches the relevant data, and persists the login session until logout or data clear.',
          'Reduced duplicated effort by replacing separate per-client codebases with one reusable, configurable architecture, making new client onboarding and releases faster.',
        ],
      ),
      _ExperienceData(
        company: 'iCodeBees Pvt Ltd.',
        role: 'Software Developer',
        duration: 'June 2024 – June 2026',
        topColor: const Color(0xFF0052CC),
        logoText: 'iB',
        bullets: [
          'Designed, developed, and debugged production-ready Flutter apps.',
          'Integrated Stripe & CashFree payment gateways and Google Maps SDK.',
          'Hands on experience in E-commerce Applications.',
          'Implemented GetX, Bloc state management and Clean Architecture patterns.',
          'Uploaded App in Google Play and App Store.',
        ],
      ),
      _ExperienceData(
        company: 'Acube Innovations',
        role: 'Software Developer',
        duration: 'Dec 2023 – Apr 2024',
        topColor: const Color(0xFF7A1C0E),
        logoText: 'Ac',
        bullets: [
          'Developed A3Sola salesperson app integrating Hive local storage and ERPNext backend.',
          'Participated in sprint planning, code reviews, and agile development workflows',
          'Developed Jambo Taxi ride-hailing driver app with real-time features.',
          'Collaborated with backend developers to consume REST APIs via Dio.',
        ],
      ),
      _ExperienceData(
        company: 'Weberfox Technologies',
        role: 'Flutter Developer Intern',
        duration: 'May 2023 – July 2023',
        topColor: const Color(0xFFCB4343),
        logoText: 'Wf',
        bullets: [
          'Designed and developed Flutter UI components from design mockups.',
          'Built a personal project using Flutter and Firebase backend tools.',
          'Built Apps using GetX, Bloc.',
          'Gained hands-on experience in Flutter widget lifecycles and state.',
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isDesktop
              ? Column(
                  children: workHistory
                      .map(
                        (data) => Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _ExperienceCard(
                            data: data,
                            textTheme: textTheme,
                            isDesktop: true,
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: workHistory
                      .map(
                        (data) => Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: _ExperienceCard(
                            data: data,
                            textTheme: textTheme,
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
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

  _ExperienceData({
    required this.company,
    required this.role,
    required this.duration,
    required this.topColor,
    required this.logoText,
    required this.bullets,
  });
}

// Turned into a StatefulWidget to track local hover state dynamically
class _ExperienceCard extends StatefulWidget {
  final _ExperienceData data;
  final TextTheme textTheme;
  final bool isDesktop;

  const _ExperienceCard({Key? key, required this.data, required this.textTheme, this.isDesktop = false})
    : super(key: key);

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        constraints: widget.isDesktop ? const BoxConstraints(minHeight: 230) : null,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? widget.data.topColor : Colors.white10,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.topColor.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: widget.isDesktop ? _buildDesktop() : _buildMobile(),
        ),
      ),
    );
  }

  Widget _buildDesktop() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logoBadge(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.company,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.data.role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                widget.data.duration,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              final grouped = _distributeBullets(widget.data.bullets, columns);
              final children = <Widget>[];
              for (int i = 0; i < grouped.length; i++) {
                if (i > 0) children.add(const SizedBox(width: 20));
                children.add(
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: grouped[i].map(_bullet).toList(),
                    ),
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: widget.data.topColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              widget.data.company,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 24.0),
          child: Column(
            children: [
              Text(
                widget.data.role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.data.duration,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 20),
              Column(children: widget.data.bullets.map(_bullet).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logoBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: widget.data.topColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.data.topColor.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          widget.data.logoText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _bullet(String bullet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.circle,
                size: 6,
                color: _isHovered ? widget.data.topColor : Colors.grey[400],
              ),
            ),
          ),
          Expanded(
            child: Text(
              bullet,
              style: TextStyle(color: Colors.grey[300], fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  List<List<String>> _distributeBullets(List<String> bullets, int columns) {
    final grouped = List<List<String>>.generate(columns, (_) => <String>[]);
    final lengths = List<double>.filled(columns, 0);
    for (final bullet in bullets) {
      int target = 0;
      for (int i = 1; i < columns; i++) {
        if (lengths[i] < lengths[target]) target = i;
      }
      grouped[target].add(bullet);
      lengths[target] += bullet.length.toDouble();
    }
    return grouped.where((list) => list.isNotEmpty).toList();
  }
}