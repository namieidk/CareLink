// ──────────────────────────────────────────────────────────────
// doc_sign_up.dart
// ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'docsign.dart';                // <-- Doctor Sign-In screen
import 'package:carelink/auth_service.dart';

class DocSignUpScreen extends StatefulWidget {
  const DocSignUpScreen({Key? key}) : super(key: key);

  @override
  State<DocSignUpScreen> createState() => _DocSignUpScreenState();
}

class _DocSignUpScreenState extends State<DocSignUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _doctorIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _floatingController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this)
          ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    _doctorIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // SIGN UP HANDLER
  // ──────────────────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await _authService.signUpDoctor(
        doctorId: _doctorIdController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fullName: null, // you can add a name field later
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        _showSuccess(result['message'] ?? 'Account created');
        // Auto-login after successful registration
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DocSignInScreen()));
      } else {
        _showError(result['error'] ?? 'Sign-up failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Unexpected error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────
  // VALIDATION
  // ──────────────────────────────────────────────────────────────
  String? _validateDoctorId(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter Doctor ID' : null;

  String? _validateUsername(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter Username' : null;

  String? _validatePassword(String? v) =>
      (v == null || v.isEmpty) ? 'Enter password' : (v.length < 6) ? 'Min 6 chars' : null;

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) return 'Passwords do not match';
    return _validatePassword(v);
  }

  // ──────────────────────────────────────────────────────────────
  // UI HELPERS
  // ──────────────────────────────────────────────────────────────
  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ]),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ]),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;
    final double hp = isWeb ? size.width * 0.08 : 42.0;
    final double panelTop = size.height * 0.25;
    final double logoTop = size.height * 0.08;
    final double logoSize = isWeb ? 160 : 140;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (_, __) => CustomPaint(
                painter: ModernBackgroundPainter(_floatingController.value),
              ),
            ),
          ),

          // LOGO
          Positioned(
            left: hp,
            right: hp,
            top: logoTop,
            height: logoSize + 40,
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: logoSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => CustomPaint(
                  size: Size(logoSize, logoSize),
                  painter: CareLinkLogoPainter(),
                ),
              ),
            ),
          ),

          // White panel
          Positioned(
            left: 0,
            right: 0,
            top: panelTop,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isWeb ? 60 : 50),
                    topRight: Radius.circular(isWeb ? 60 : 50)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, -8)),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                  hp, isWeb ? size.height * 0.05 : 32, hp, isWeb ? size.height * 0.04 : 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text('Sign up',
                            style: TextStyle(
                                fontSize: isWeb ? 42 : 36,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF424242))),
                        Container(
                            width: 60,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF8383),
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 24),

                        // Doctor ID
                        _buildField(
                            label: 'Doctor ID',
                            controller: _doctorIdController,
                            icon: Icons.badge_outlined,
                            validator: _validateDoctorId,
                            isWeb: isWeb),
                        const SizedBox(height: 16),

                        // Username
                        _buildField(
                            label: 'Username',
                            controller: _usernameController,
                            icon: Icons.person_outline,
                            validator: _validateUsername,
                            isWeb: isWeb),
                        const SizedBox(height: 16),

                        // Password
                        _buildField(
                            label: 'Password',
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscure: _obscurePass,
                            validator: _validatePassword,
                            isWeb: isWeb,
                            suffix: IconButton(
                                icon: Icon(
                                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFFBDBDBD),
                                    size: 20),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass))),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscure: _obscureConfirm,
                            validator: _validateConfirm,
                            isWeb: isWeb,
                            suffix: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                    color: const Color(0xFFBDBDBD),
                                    size: 20),
                                onPressed: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm))),
                        const SizedBox(height: 28),

                        // Create button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8383),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 8,
                              shadowColor: const Color(0xFFFF8383).withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text('Create Account',
                                    style: TextStyle(
                                        fontSize: isWeb ? 20 : 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login link
                        Center(
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: isWeb ? 16 : 14,
                                    color: const Color(0xFF9E9E9E)),
                                children: [
                                  const TextSpan(text: "Already have an Account? "),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: _isLoading
                                          ? null
                                          : () {
                                              HapticFeedback.lightImpact();
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const DocSignInScreen()));
                                            },
                                      child: Text('Login',
                                          style: TextStyle(
                                              color: _isLoading
                                                  ? const Color(0xFFBDBDBD)
                                                  : const Color(0xFFFF8383),
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFFF8383)),
                          SizedBox(height: 16),
                          Text('Creating account...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    String? Function(String?)? validator,
    required bool isWeb,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF424242))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          enabled: !_isLoading,
          style: TextStyle(fontSize: isWeb ? 16 : 14, color: const Color(0xFF424242)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFBDBDBD), size: 20),
            suffixIcon: suffix,
            hintText: isPassword ? 'Enter password' : 'Enter $label',
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFFBDBDBD).withOpacity(0.5))),
            focusedBorder:
                const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF8383), width: 2)),
            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red.shade300)),
            focusedErrorBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.red.shade400, width: 2)),
            errorStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// PAINTERS (identical to sign-in)
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
        colors: [Color(0xFFFFCCCC), Color(0xFFFFB5B5), Color(0xFFFF9999), Color(0xFFFF8383)],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.75));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.75), gradientPaint);

    _drawFloatingBlob(canvas,
        Offset(size.width * 0.15, size.height * 0.15 + math.sin(animation * math.pi * 2) * 20), 80,
        Colors.white.withOpacity(0.15));
    _drawFloatingBlob(canvas,
        Offset(size.width * 0.85, size.height * 0.25 + math.cos(animation * math.pi * 2 + 1) * 25),
        100, Colors.white.withOpacity(0.12));
    _drawFloatingBlob(canvas,
        Offset(size.width * 0.5, size.height * 0.08 + math.sin(animation * math.pi * 2 + 2) * 15), 60,
        Colors.white.withOpacity(0.18));
    _drawFloatingBlob(canvas,
        Offset(size.width * 0.2, size.height * 0.4 + math.cos(animation * math.pi * 2 + 3) * 18), 90,
        Colors.white.withOpacity(0.1));
    _drawFloatingBlob(canvas,
        Offset(size.width * 0.75, size.height * 0.45 + math.sin(animation * math.pi * 2 + 4) * 22),
        110, Colors.white.withOpacity(0.08));

    _drawDecorativeCurves(canvas, size, animation);
    _drawTopographicLines(canvas, size);
  }

  void _drawFloatingBlob(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius, paint);
    final inner = Paint()
      ..color = color.withOpacity(color.opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius * 0.6, inner);
  }

  void _drawDecorativeCurves(Canvas canvas, Size size, double animation) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final p1 = Path();
    p1.moveTo(size.width * 0.1, size.height * 0.2);
    p1.quadraticBezierTo(
        size.width * 0.3, size.height * 0.15 + math.sin(animation * math.pi * 2) * 10,
        size.width * 0.5, size.height * 0.25);
    p1.quadraticBezierTo(size.width * 0.7, size.height * 0.35, size.width * 0.9, size.height * 0.3);
    canvas.drawPath(p1, paint);
    final p2 = Path();
    p2.moveTo(size.width * 0.05, size.height * 0.5);
    p2.cubicTo(
        size.width * 0.25, size.height * 0.48 + math.cos(animation * math.pi * 2 + 1) * 8,
        size.width * 0.5, size.height * 0.52, size.width * 0.75, size.height * 0.5);
    canvas.drawPath(p2, paint);
  }

  void _drawTopographicLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 35);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 50);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.15, size.height * 0.12), 65);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 40);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 60);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.85, size.height * 0.2), 80);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.2, size.height * 0.42), 45);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.2, size.height * 0.42), 65);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.75, size.height * 0.5), 50);
    _drawOrganicCircle(canvas, paint, Offset(size.width * 0.75, size.height * 0.5), 75);
  }

  void _drawOrganicCircle(Canvas canvas, Paint paint, Offset center, double radius) {
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant ModernBackgroundPainter old) => animation != old.animation;
}

class CareLinkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF888888)..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.35);
    path.cubicTo(size.width * 0.2, size.height * 0.15, size.width * 0.1, size.height * 0.35,
        size.width * 0.5, size.height * 0.75);
    path.moveTo(size.width * 0.5, size.height * 0.35);
    path.cubicTo(size.width * 0.8, size.height * 0.15, size.width * 0.9, size.height * 0.35,
        size.width * 0.5, size.height * 0.75);
    canvas.drawPath(path, paint);
    final house = Path();
    house.moveTo(size.width * 0.7, size.height * 0.25);
    house.lineTo(size.width * 0.85, size.height * 0.15);
    house.lineTo(size.width * 0.92, size.height * 0.2);
    house.lineTo(size.width * 0.92, size.height * 0.28);
    house.lineTo(size.width * 0.7, size.height * 0.35);
    house.close();
    canvas.drawPath(house, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}