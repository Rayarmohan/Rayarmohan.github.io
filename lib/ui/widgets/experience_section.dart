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
        company: 'iCodeBees Pvt Ltd.',
        role: 'Software Developer',
        duration: 'June 2024 – Present',
        topColor: const Color(0xFF0052CC),
        logoText: 'iB',
        bullets: [
          'Designed, developed, and debugged production-ready Flutter apps.',
          'Integrated Stripe & CashFree payment gateways and Google Maps SDK.',
          'Hands on experienece in E-commerce Applications'
          'Implemented GetX, Bloc state management and Clean Architecture patterns.',
          ' Uploaded App in Google Play and App Store.'
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
          'Built Apps using GetX, Bloc'
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
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: workHistory
                      .map(
                        (data) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: _ExperienceCard(
                              data: data,
                              textTheme: textTheme,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: workHistory
                      .map(
                        (data) => Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
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

  const _ExperienceCard({Key? key, required this.data, required this.textTheme})
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
        duration: const Duration(milliseconds: 250), // Smooth transition timing
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          // Animates the border from white10 to the themed top color on hover
          border: Border.all(
            color: _isHovered ? widget.data.topColor : Colors.white10, 
            width: _isHovered ? 1.5 : 1.0,
          ),
          // Adds a subtle glow reflecting the card's accent color on hover
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: widget.data.topColor,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    widget.data.company,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
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
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 20),

                    Column(
                      children: widget.data.bullets.map((bullet) {
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
                                    // Bullet points slightly light up on hover
                                    color: _isHovered ? widget.data.topColor : Colors.grey[400],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  bullet,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}