import 'package:flutter/material.dart';

class WhatIDoSection extends StatelessWidget {
  const WhatIDoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive calculation: Use a 2-column grid on desktop, fallback to a single list on small viewports.
    final bool isDesktop = screenWidth > 900;

    final services = [
      _ServiceData(
        icon: Icons.phone_android_rounded,
        title: 'Crafting High-Performance Mobile Experiences',
        description: 'Expert in building scalable, native-quality cross-platform applications for iOS and Android utilizing Flutter and Dart.',
        highlightColor: const Color(0xFFA9D606), // Lime Green
      ),
      _ServiceData(
        icon: Icons.account_tree_outlined,
        title: 'Robust State Management & Clean Architecture',
        description: 'Proficient in designing maintainable codebases using robust patterns like GetX, ensuring efficient state handling and predictable data flow.',
        highlightColor: const Color(0xFF2E43FF), // Blue
      ),
      _ServiceData(
        icon: Icons.api_rounded,
        title: 'Seamless API & Feature Integration',
        description: 'Skilled in implementing robust REST APIs, real-time features, secure payment gateways, and seamless over-the-air (OTA) app updates.',
        highlightColor: const Color(0xFF2BBE38), // Emerald Green
      ),
      _ServiceData(
        icon: Icons.rocket_launch_rounded,
        title: 'End-to-End Product Deployment',
        description: 'Experienced in managing the entire development lifecycle, from initial UI conversion to successful deployment and release management on the App Store and Google Play.',
        highlightColor: const Color(0xFFA9D606), // Lime Green
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive Services Layout
        isDesktop
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  mainAxisExtent: 180, 
                ),
                itemBuilder: (context, index) => _ServiceCard(data: services[index], textTheme: textTheme),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) => _ServiceCard(data: services[index], textTheme: textTheme),
              ),
      ],
    );
  }
}

// --- Data Structure Object ---
class _ServiceData {
  final IconData icon;
  final String title;
  final String description;
  final Color highlightColor;

  _ServiceData({
    required this.icon,
    required this.title,
    required this.description,
    required this.highlightColor,
  });
}

// --- Interactive Service Card Item ---
class _ServiceCard extends StatefulWidget {
  final _ServiceData data;
  final TextTheme textTheme;

  const _ServiceCard({Key? key, required this.data, required this.textTheme}) : super(key: key);

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF111111) : const Color(0xFF070707),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? widget.data.highlightColor.withOpacity(0.5) : Colors.white10,
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.highlightColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Hover Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isHovered ? widget.data.highlightColor.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.data.icon,
                size: 32,
                color: _isHovered ? widget.data.highlightColor : Colors.grey[400],
              ),
            ),
            const SizedBox(width: 20),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.data.title,
                    style: widget.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data.description,
                    style: widget.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                      height: 1.5,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}