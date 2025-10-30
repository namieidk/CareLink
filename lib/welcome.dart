import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'welcome2.dart';   // <-- navigate to the second screen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWeb = size.width > 600;

    // Responsive values
    final double horizontalPadding = isWeb ? size.width * 0.08 : 42.0;
    final double titleFontSize = isWeb ? size.width * 0.045 : 40.0;
    final double descFontSize = isWeb ? size.width * 0.018 : 14.0;
    final double logoTopPosition = isWeb ? size.height * 0.12 : 101.0;
    final double logoHeight = isWeb ? size.height * 0.35 : 373.0;
    final double panelTopPosition = size.height * 0.58;
    final double buttonBottomPadding = isWeb ? size.height * 0.08 : 60.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ModernBackgroundPainter(_floatingController.value),
                );
              },
            ),
          ),

          // White curved panel
          Positioned(
            left: 0,
            right: 0,
            top: panelTopPosition,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isWeb ? 60 : 50),
                  topRight: Radius.circular(isWeb ? 60 : 50),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isWeb ? size.height * 0.06 : 50,
                horizontalPadding,
                buttonBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Welcome Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: titleFontSize.clamp(32.0, 56.0),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF424242),
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: isWeb ? 24 : 16),
                          Text(
                            'lorem lorem lorem lorem ',
                            style: TextStyle(
                              fontSize: descFontSize.clamp(14.0, 20.0),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              letterSpacing: 0.2,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Continue Button – NAVIGATION TO welcome2.dart
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 600),
                              pageBuilder: (_, __, ___) => const WelcomeScreen2(),
                              transitionsBuilder:
                                  (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: descFontSize.clamp(14.0, 18.0),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.2,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(width: isWeb ? 32 : 24),
                            Container(
                              width: isWeb ? 48 : 36,
                              height: isWeb ? 48 : 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF9999),
                                    Color(0xFFFF8383),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8383)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logo
          Positioned(
            left: isWeb ? horizontalPadding : 21,
            right: isWeb ? horizontalPadding : 36,
            top: logoTopPosition,
            height: logoHeight,
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => CustomPaint(
                  size: Size(
                    isWeb ? size.width * 0.25 : 200,
                    isWeb ? size.width * 0.25 : 200,
                  ),
                  painter: CareLinkLogoPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// SHARED PAINTERS (background + logo)
// ──────────────────────────────────────────────────────────────
class ModernBackgroundPainter extends CustomPainter {
  final double animation;
  ModernBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFCCCC),
          Color(0xFFFFB5B5),
          Color(0xFFFF9999),
          Color(0xFFFF8383),
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.75));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.75), gradientPaint);

    _drawFloatingBlob(
      canvas,
      Offset(size.width * 0.15,
          size.height * 0.15 + math.sin(animation * math.pi * 2) * 20),
      80,
      Colors.white.withOpacity(0.15),
    );
    _drawFloatingBlob(
      canvas,
      Offset(size.width * 0.85,
          size.height * 0.25 + math.cos(animation * math.pi * 2 + 1) * 25),
      100,
      Colors.white.withOpacity(0.12),
    );
    _drawFloatingBlob(
      canvas,
      Offset(size.width * 0.5,
          size.height * 0.08 + math.sin(animation * math.pi * 2 + 2) * 15),
      60,
      Colors.white.withOpacity(0.18),
    );
    _drawFloatingBlob(
      canvas,
      Offset(size.width * 0.2,
          size.height * 0.4 + math.cos(animation * math.pi * 2 + 3) * 18),
      90,
      Colors.white.withOpacity(0.1),
    );
    _drawFloatingBlob(
      canvas,
      Offset(size.width * 0.75,
          size.height * 0.45 + math.sin(animation * math.pi * 2 + 4) * 22),
      110,
      Colors.white.withOpacity(0.08),
    );

    _drawDecorativeCurves(canvas, size, animation);
    _drawTopographicLines(canvas, size);
  }

  void _drawFloatingBlob(
      Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius, paint);

    final innerPaint = Paint()
      ..color = color.withOpacity(color.opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  void _drawDecorativeCurves(
      Canvas canvas, Size size, double animation) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path1 = Path();
    path1.moveTo(size.width * 0.1, size.height * 0.2);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.15 + math.sin(animation * math.pi * 2) * 10,
      size.width * 0.5,
      size.height * 0.25,
    );
    path1.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.35,
      size.width * 0.9,
      size.height * 0.3,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.05, size.height * 0.5);
    path2.cubicTo(
      size.width * 0.25,
      size.height * 0.48 + math.cos(animation * math.pi * 2 + 1) * 8,
      size.width * 0.5,
      size.height * 0.52,
      size.width * 0.75,
      size.height * 0.5,
    );
    canvas.drawPath(path2, paint);
  }

  void _drawTopographicLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 35);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 50);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 65);

    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 40);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 60);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 80);

    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.2, size.height * 0.42), 45);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.2, size.height * 0.42), 65);

    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.75, size.height * 0.5), 50);
    _drawOrganicCircle(
        canvas, paint, Offset(size.width * 0.75, size.height * 0.5), 75);
  }

  void _drawOrganicCircle(
      Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ModernBackgroundPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

class CareLinkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.35);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.15,
      size.width * 0.1,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.75,
    );
    path.moveTo(size.width * 0.5, size.height * 0.35);
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.15,
      size.width * 0.9,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.75,
    );
    canvas.drawPath(path, paint);

    final housePath = Path();
    housePath.moveTo(size.width * 0.7, size.height * 0.25);
    housePath.lineTo(size.width * 0.85, size.height * 0.15);
    housePath.lineTo(size.width * 0.92, size.height * 0.2);
    housePath.lineTo(size.width * 0.92, size.height * 0.28);
    housePath.lineTo(size.width * 0.7, size.height * 0.35);
    housePath.close();
    canvas.drawPath(housePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}