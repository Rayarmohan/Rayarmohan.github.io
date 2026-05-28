import 'package:flutter/material.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Mapping your resume education details directly to the UI list layout configuration
    final educationHistory = [
      _EducationData(
        institution: 'Cochin University of Science and Technology',
        degree: 'M.Voc Mobile Phone Application Development',
        duration: 'June 2022 – June 2024',
        grade: 'CGPA : 7.8/10',
        logoAsset:
            'cusat_logo.png', // Placeholder path -> replace with yours
        accentColor: const Color.fromARGB(255, 200, 230, 92), // Tech Blue
      ),
      _EducationData(
        institution: 'MG University',
        degree: 'B.Sc Computer Science',
        duration: 'July 2019 – March 2022',
        grade: 'CGPA : 7.6/10',
        logoAsset:
            'mg_logo.jpg', // Placeholder path -> replace with yours
        accentColor: const Color.fromARGB(255, 212, 221, 82), // Vibrant Accent Red
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: educationHistory
                .map(
                  (data) => Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _EducationRowCard(data: data),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// --- Internal Education Blueprint Data Object ---
class _EducationData {
  final String institution;
  final String degree;
  final String duration;
  final String grade;
  final String logoAsset;
  final Color accentColor;

  _EducationData({
    required this.institution,
    required this.degree,
    required this.duration,
    required this.grade,
    required this.logoAsset,
    required this.accentColor,
  });
}

// --- Standalone Interactive Responsive Education Card ---
class _EducationRowCard extends StatefulWidget {
  final _EducationData data;

  const _EducationRowCard({Key? key, required this.data}) : super(key: key);

  @override
  State<_EducationRowCard> createState() => _EducationRowCardState();
}

class _EducationRowCardState extends State<_EducationRowCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Breakpoint tracking for layout changes (Mobile vs Desktop row configurations)
    final bool isMobile = screenWidth < 768;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF111111) : const Color(0xFF070707),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.data.accentColor.withOpacity(0.5)
                : Colors.white10,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.accentColor.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Subtle Animated side accent border strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHovered ? 5 : 0,
                  color: widget.data.accentColor,
                ),
              ),

              // Core Information Content Layout
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: isMobile
                      ? 16.0
                      : 24.0, // Adapts side padding to maximize workspace on small screens
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Institution Logo Avatar block
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: isMobile
                            ? 58
                            : 80, // Scales logo slightly down on mobile viewports
                        height: isMobile ? 58 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: _isHovered
                                ? widget.data.accentColor
                                : Colors.white24,
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipOval(
                          child: Image.asset(
                            widget.data.logoAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.school_outlined,
                                color: _isHovered
                                    ? widget.data.accentColor
                                    : Colors.grey[400],
                                size: isMobile ? 22 : 28,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),

                    // Academic text metadata block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Layout switches context smoothly depending on screen space
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.data.institution,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.data.duration,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.data.institution,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.data.duration,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 8),
                          Text(
                            widget.data.degree,
                            style: TextStyle(
                              color: widget.data.accentColor.withOpacity(0.9),
                              fontSize: isMobile ? 14.5 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.data.grade,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: isMobile ? 13 : 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
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
