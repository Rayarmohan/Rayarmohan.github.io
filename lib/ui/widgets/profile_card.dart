import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ProfileCardTheme { dark, light }

class ProfileCard extends StatefulWidget {
  final String? avatarUrl;
  final String? iconUrl;
  final String? miniAvatarUrl;
  final String name;
  final String title;
  final String handle;
  final String status;
  final Color statusColor;
  final String contactText;
  final bool showUserInfo;
  final VoidCallback? onContactClick;
  final ProfileCardTheme theme;
  final Color? backdropColor;
  final double radius;
  final double holo;
  final double glare;
  final bool enableTilt;
  final double tiltStrength;
  final double parallax;
  final bool enableMobileTilt;
  final double mobileTiltSensitivity;
  final bool intro;
  final double width;

  const ProfileCard({
    super.key,
    this.avatarUrl,
    this.iconUrl,
    this.miniAvatarUrl,
    this.name = 'Javi A. Torres',
    this.title = 'Software Engineer',
    this.handle = 'javicodes',
    this.status = 'Online',
    this.statusColor = const Color(0xFF22C55E),
    this.contactText = 'Contact',
    this.showUserInfo = true,
    this.onContactClick,
    this.theme = ProfileCardTheme.dark,
    this.backdropColor,
    this.radius = 16,
    this.holo = 0.8,
    this.glare = 0.5,
    this.enableTilt = true,
    this.tiltStrength = 12,
    this.parallax = 8,
    this.enableMobileTilt = false,
    this.mobileTiltSensitivity = 5,
    this.intro = true,
    this.width = 340,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _Spring {
  double p = 0;
  double v = 0;
  double target = 0;

  void step(double stiffness, double damping, double h) {
    v += (stiffness * (target - p) - damping * v) * h;
    p += v * h;
  }

  bool get settled => (target - p).abs() < 0.0005 && v.abs() < 0.0005;
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _clock = Stopwatch();
  Duration? _lastTick;

  final _Spring _x = _Spring();
  final _Spring _y = _Spring();
  final _Spring _light = _Spring();

  bool _contactHovered = false;

  bool get _isDark => widget.theme == ProfileCardTheme.dark;

  Color get _ink =>
      _isDark ? const Color(0xFFF4F4F5) : const Color(0xFF27272A);
  Color get _muted => _isDark
      ? Colors.white.withValues(alpha: 0.60)
      : const Color(0xFF27272A).withValues(alpha: 0.60);
  Color get _frame =>
      _isDark ? const Color(0xA826232E) : const Color(0xCCF0F0F3);
  Color get _frameEdge => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);
  Color get _tileEdge => _isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.08);
  Color get _shade => _isDark
      ? Colors.black.withValues(alpha: 0.40)
      : Colors.black.withValues(alpha: 0.14);

  List<Color> get _tileGradient {
    if (widget.backdropColor != null) {
      final c = widget.backdropColor!;
      return [Color.lerp(c, Colors.white, 0.12)!, Color.lerp(c, Colors.black, 0.18)!];
    }
    return _isDark
        ? const [Color(0xFF3A3644), Color(0xFF27242F)]
        : const [Color(0xFFFFFFFF), Color(0xFFF6F6F8)];
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _clock.start();

    if (widget.intro) {
      _x.p = 0.62;
      _y.p = -0.55;
      _light.p = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _wake();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.stop();
    super.dispose();
  }

  double get _seconds => _clock.elapsedMicroseconds / 1e6;

  void _wake() {
    if (_ticker.isActive) return;
    _lastTick = null;
    _ticker.start();
  }

  void _aimAt(Offset local, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _x.target = ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    _y.target = ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    _light.target = 1;
    _wake();
  }

  void _release() {
    _x.target = 0;
    _y.target = 0;
    _light.target = 0;
    _wake();
  }

  void _onTick(Duration elapsed) {
    final double dt = _lastTick == null
        ? 1 / 60
        : (elapsed - _lastTick!).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final double d = dt.clamp(0.0, 0.05);
    final bool slow = _seconds < 1.4;
    final double stiffness = slow ? 24 : 120;
    final double damping = slow ? 9 : 16;

    final int steps = math.max(1, (d / (1 / 120)).ceil());
    final double h = d / steps;
    for (int i = 0; i < steps; i++) {
      _x.step(stiffness, damping, h);
      _y.step(stiffness, damping, h);
    }

    final double tau = _light.target > _light.p
        ? 0.18
        : (slow ? 0.9 : 0.45);
    _light.p += (_light.target - _light.p) * (1 - math.exp(-d / tau));

    final bool moving = !_x.settled ||
        !_y.settled ||
        (_light.target - _light.p).abs() > 0.002;

    setState(() {});

    if (!moving) {
      _x.p = _x.target;
      _y.p = _y.target;
      _light.p = _light.target;
      _lastTick = null;
      _ticker.stop();
      setState(() {});
    }
  }

  double _heightFor(double width) {
    final double tileWidth = width - 20;
    final double tileHeight = tileWidth * 1.25;
    final double gap = widget.showUserInfo ? 10 : 0;
    final double footer = widget.showUserInfo ? 50 : 0;
    return tileHeight + gap + footer + 20;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final Size size = Size(w, _heightFor(w));

          final double angle = widget.enableTilt ? widget.tiltStrength : 0.0;
          final double tiltRad = angle * math.pi / 180;
          final Matrix4 transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_y.p * tiltRad)
            ..rotateY(-_x.p * tiltRad);

          return MouseRegion(
            cursor: SystemMouseCursors.basic,
            onEnter: (e) => _aimAt(e.localPosition, size),
            onHover: (e) => _aimAt(e.localPosition, size),
            onExit: (_) => _release(),
            child: GestureDetector(
              onPanStart: (e) => _aimAt(e.localPosition, size),
              onPanUpdate: (e) => _aimAt(e.localPosition, size),
              onPanEnd: (_) => _release(),
              onPanCancel: _release,
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: _buildBody(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final double bodyRadius = widget.radius + 10;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(bodyRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 44,
            spreadRadius: -20,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: -8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(bodyRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _frame,
              borderRadius: BorderRadius.circular(bodyRadius),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTile(),
                      if (widget.showUserInfo) ...[
                        const SizedBox(height: 10),
                        _buildFooter(),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(bodyRadius),
                        border: Border.all(color: _frameEdge),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile() {
    final double radius = widget.radius;
    final double reach = math.min(1, math.sqrt(_x.p * _x.p + _y.p * _y.p));
    final double active = _light.p;
    final double tiltAmt = reach * active;
    final double parallax = widget.parallax;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _tileGradient,
                ),
              ),
            ),
            IgnorePointer(
              child: Opacity(
                opacity:
                    (widget.holo * 0.75 * (0.5 + 0.5 * active)).clamp(0.0, 0.9),
                child: CustomPaint(
                  painter: _FoilPainter(
                    pointerU: (_x.p + 1) * 0.5,
                    pointerV: (_y.p + 1) * 0.5,
                    dark: _isDark,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: (widget.holo * active).clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(_x.p * 0.9, _y.p * 0.9),
                      radius: 0.95,
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: (widget.glare * tiltAmt).clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(_x.p, _y.p),
                      radius: 1.05,
                      stops: const [0.30, 1.0],
                      colors: [Colors.transparent, _shade],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.avatarUrl != null)
              Positioned(
                left: -parallax,
                top: -parallax,
                right: -parallax,
                bottom: -parallax,
                child: Transform.translate(
                  offset: Offset(_x.p * parallax, _y.p * parallax),
                  child: Image(
                    image: _resolveImage(widget.avatarUrl!),
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (context, error, stack) =>
                        _portraitFallback(),
                  ),
                ),
              )
            else
              _portraitFallback(),
            if (widget.name.isNotEmpty || widget.title.isNotEmpty) ...[
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.0, 0.52, 1.0],
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.name.isNotEmpty)
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                    if (widget.title.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xC7FFFFFF),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: _tileEdge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _portraitFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _tileGradient,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: widget.width * 0.22,
          color: Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final double radius = widget.radius;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Row(
        children: [
          if (widget.miniAvatarUrl != null) ...[
            ClipOval(
              child: SizedBox(
                width: 36,
                height: 36,
                child: Image(
                  image: _resolveImage(widget.miniAvatarUrl!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stack) => ColoredBox(
                    color: _tileGradient.last,
                    child: Icon(Icons.person,
                        size: 20, color: _ink.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.handle.isNotEmpty)
                  Text(
                    widget.handle.startsWith('@')
                        ? widget.handle
                        : '@${widget.handle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                if (widget.status.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (widget.contactText.isNotEmpty)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _contactHovered = true),
              onExit: (_) => setState(() => _contactHovered = false),
              child: GestureDetector(
                onTap: widget.onContactClick,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _tileGradient,
                    ),
                    borderRadius: BorderRadius.circular(radius * 0.75),
                    border: Border.all(color: _tileEdge),
                    boxShadow: [
                      BoxShadow(
                        color: _contactHovered
                            ? Colors.black.withValues(alpha: 0.30)
                            : Colors.black.withValues(alpha: 0.45),
                        blurRadius: _contactHovered ? 12 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mail_outline_rounded,
                          size: 16, color: _ink),
                      const SizedBox(width: 6),
                      Text(
                        widget.contactText,
                        style: TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider _resolveImage(String source) {
    final String path = source.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }
}

class _FoilPainter extends CustomPainter {
  final double pointerU;
  final double pointerV;
  final bool dark;

  _FoilPainter({
    required this.pointerU,
    required this.pointerV,
    required this.dark,
  });

  static const List<Color> _spectrum = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD166),
    Color(0xFF9BE564),
    Color(0xFF6BE8E0),
    Color(0xFF7C9CFF),
    Color(0xFFC792EA),
    Color(0xFFFF6B6B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final Rect rect = Offset.zero & size;
    final double angle =
        (pointerU - 0.5) * 1.4 + (pointerV - 0.5) * 0.8;

    final List<Color> colors =
        _spectrum.map((c) => c.withValues(alpha: 0.55)).toList();

    canvas.saveLayer(
      rect,
      Paint()..blendMode = dark ? BlendMode.overlay : BlendMode.multiply,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(
            math.cos(angle) * -1.3,
            math.sin(angle) * -1.3,
          ),
          end: Alignment(
            math.cos(angle) * 1.3,
            math.sin(angle) * 1.3,
          ),
          colors: colors,
          tileMode: TileMode.mirror,
        ).createShader(rect),
    );

    final Paint stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = math.max(3, size.width * 0.015);
    final double step = size.width * 0.12;
    for (double d = -size.height; d < size.width; d += step) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        stripePaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoilPainter oldDelegate) {
    return oldDelegate.pointerU != pointerU ||
        oldDelegate.pointerV != pointerV ||
        oldDelegate.dark != dark;
  }
}
