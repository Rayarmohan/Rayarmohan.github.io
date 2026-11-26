import 'package:flutter/material.dart';

class HoverShiningNavButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool compact;

  const HoverShiningNavButton({
    Key? key,
    required this.text,
    this.onTap,
    this.compact = false,
  }) : super(key: key);

  @override
  State<HoverShiningNavButton> createState() => _HoverShiningNavButtonState();
}

class _HoverShiningNavButtonState extends State<HoverShiningNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.compact ? 38 : 44;
    final double outerRadius = height / 2;
    final double innerRadius = outerRadius - 2;
    final double hPad = widget.compact ? 14 : 20;
    final double fontSize = widget.compact ? 12.5 : 14;
    final double letterSpacing = widget.compact ? 0.7 : 1.1;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return IntrinsicWidth(
            child: Container(
              height: height,
              padding: const EdgeInsets.all(2.0), // Shining border thickness ring
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerRadius),
                // We keep the SweepGradient active but toggle its visibility with opacity
                // to prevent the AnimatedContainer layout from collapsing the string text boundary box
                gradient: SweepGradient(
                  center: Alignment.center,
                  transform: GradientRotation(_controller.value * 2 * 3.141592653589793),
                  colors: [
                    const Color(0xFFA9D606).withOpacity(_isHovered ? 1.0 : 0.0),
                    const Color(0xFF2E43FF).withOpacity(_isHovered ? 1.0 : 0.0),
                    const Color(0xFF2BBE38).withOpacity(_isHovered ? 1.0 : 0.0),
                    const Color(0xFFA9D606).withOpacity(_isHovered ? 1.0 : 0.0),
                  ],
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                decoration: BoxDecoration(
                  color: Colors.black, 
                  borderRadius: BorderRadius.circular(innerRadius),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(innerRadius),
                  hoverColor: Colors.transparent, 
                  splashColor: Colors.white10,
                  child: Center(
                    child: Text(
                      widget.text,
                      maxLines: 1,       // FORCE 1: Prevents breaking to a second line
                      softWrap: false,   // FORCE 2: Disables wrapping engine logic checks entirely
                      overflow: TextOverflow.visible, // Ensures text doesn't unexpectedly clip 
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: letterSpacing,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}