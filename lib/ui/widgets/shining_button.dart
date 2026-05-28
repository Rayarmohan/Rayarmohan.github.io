import 'package:flutter/material.dart';

class ShiningButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const ShiningButton({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  State<ShiningButton> createState() => _ShiningButtonState();
}

class _ShiningButtonState extends State<ShiningButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
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
        // IntrinsicWidth forces the outer container to wrap exactly to the size of its child
        return IntrinsicWidth(
          child: Container(
            height: 50,
            padding: const EdgeInsets.all(2.5), // Shiny border thickness ring
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25), 
              gradient: SweepGradient(
                center: Alignment.center,
                transform: GradientRotation(_controller.value * 2 * 3.141592653589793), 
                colors: const [
                  Color(0xFFA9D606), 
                  Color(0xFF2E43FF), 
                  Color(0xFF2BBE38), 
                  Color(0xFFA9D606), 
                ],
              ),
            ),
            child: Container(
              // Adding symmetrical horizontal padding gives the button breathing room on the edges
              padding: const EdgeInsets.symmetric(horizontal: 24.0), 
              decoration: BoxDecoration(
                color: Colors.black, 
                borderRadius: BorderRadius.circular(23), 
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(23),
                child: Center(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}