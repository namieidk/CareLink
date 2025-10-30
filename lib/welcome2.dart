// lib/welcome2.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'patient/signin.dart';   // Patient → SignInScreen
import 'staff.dart' as staff;    // Staff → WelcomeScreen2 from staff.dart

// -----------------------------------------------------------------
// PAINTERS (same as before)
// -----------------------------------------------------------------
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

// -----------------------------------------------------------------
// SECOND SCREEN – Staff → staff.WelcomeScreen2, Patient → SignInScreen
// -----------------------------------------------------------------
class WelcomeScreen2 extends StatefulWidget {
  const WelcomeScreen2({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _selectedRole = ''; // '' = none, 'staff' or 'patient'

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

  // -----------------------------------------------------------------
  // Handle role selection
  // -----------------------------------------------------------------
  void _handleRoleSelection(String role) {
    HapticFeedback.selectionClick();
    setState(() => _selectedRole = role);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (role == 'patient') {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const SignInScreen(),
            transitionsBuilder: (_, animation, __, child) {
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
      } else if (role == 'staff') {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const staff.WelcomeScreen2(), // FIXED: Using the correct class name from staff.dart
            transitionsBuilder: (_, animation, __, child) {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWeb = size.width > 600;

    final double horizontalPadding = isWeb ? size.width * 0.08 : 42.0;
    final double descFontSize = isWeb ? size.width * 0.018 : 14.0;
    final double logoTopPosition = isWeb ? size.height * 0.12 : 101.0;
    final double logoHeight = isWeb ? size.height * 0.35 : 373.0;
    final double panelTopPosition = size.height * 0.58;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated background
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
                isWeb ? size.height * 0.04 : 32,
                horizontalPadding,
                isWeb ? size.height * 0.05 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Description
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Lorem ipsum dolor sit amet consectetur.\nLorem id sit',
                        style: TextStyle(
                          fontSize: descFontSize.clamp(14.0, 18.0),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 0.2,
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),

                  // Role buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildRoleButton(
                              'Staff',
                              'staff',
                              const Color(0xFFFFCCCC),
                              const Color(0xFF8B0000),
                              isWeb,
                            ),
                          ),
                          SizedBox(width: isWeb ? 24 : 16),
                          Expanded(
                            child: _buildRoleButton(
                              'Patient',
                              'patient',
                              const Color(0xFFD4B5E8),
                              const Color(0xFF6B2C91),
                              isWeb,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // REMOVED: Continue button section
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

  Widget _buildRoleButton(
    String label,
    String role,
    Color bgColor,
    Color textColor,
    bool isWeb,
  ) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _handleRoleSelection(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isWeb ? 20 : 16,
          horizontal: isWeb ? 24 : 16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
          border: Border.all(
            color: isSelected ? textColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: textColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}