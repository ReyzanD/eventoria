import 'package:eventoria/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authControllerProvider.notifier)
          .login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            onError: (errorMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showEmailForm
                      ? _buildEmailForm(isLoading)
                      : _buildWelcomeContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const VenuLogo(fontSize: 72),
        const SizedBox(height: 70),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _showEmailForm = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF45E65),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Continue with email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Sign-In is mocked for this demo.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3B4FEB),
            side: const BorderSide(color: Color(0xFF3B4FEB)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: Size(20, 20),
                painter: GoogleLogoPainter(),
              ),
              SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Continue with Apple button
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apple Sign-In is mocked for this demo.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3B4FEB),
            side: const BorderSide(color: Color(0xFF3B4FEB)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: Size(20, 20),
                painter: AppleLogoPainter(),
              ),
              SizedBox(width: 12),
              Text(
                'Continue with Apple',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Already have an account? Sign in
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: Color(0xFF717F8C), fontSize: 15),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showEmailForm = true;
                });
              },
              child: const Text(
                'Sign in',
                style: TextStyle(
                  color: Color(0xFF3B4FEB),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Terms & Privacy
        const Text(
          'By continuing you agree to Terms & Privacy',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF717F8C), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('email_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3B4FEB)),
                onPressed: () {
                  setState(() {
                    _showEmailForm = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const VenuLogo(fontSize: 48),
          const SizedBox(height: 40),

          // Email Field
          const Text(
            'EMAIL ADDRESS',
            style: TextStyle(
              color: Color(0xFF717F8C),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(hintText: 'name@example.com'),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          const Text(
            'PASSWORD',
            style: TextStyle(
              color: Color(0xFF717F8C),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF717F8C),
                ),
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Forgot Password Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF3B4FEB)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign In Button
          ElevatedButton(
            onPressed: isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF45E65),
              disabledBackgroundColor: const Color(0xFFF45E65).withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Sign Up Link Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: Color(0xFF717F8C)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF3B4FEB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      errorStyle: const TextStyle(color: Colors.redAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B4FEB), width: 2),
      ),
    );
  }
}

class VenuLogo extends StatelessWidget {
  final double fontSize;
  const VenuLogo({super.key, this.fontSize = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  'v',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3B4FEB),
                    letterSpacing: -1.0,
                  ),
                ),
                Positioned(
                  top: -fontSize * 0.1,
                  left: fontSize * 0.12,
                  child: Container(
                    width: fontSize * 0.28,
                    height: fontSize * 0.28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF45E65),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'enu',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3B4FEB),
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        SizedBox(height: fontSize * 0.1),
        Text(
          'Find your next moment.',
          style: TextStyle(
            fontSize: fontSize * 0.25,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF717F8C),
          ),
        ),
      ],
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double arcRadius = radius - paint.strokeWidth / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: arcRadius);

    // Red arc (top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.8, -3.14159 * 0.7, false, paint);

    // Yellow arc (left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.14159 * 0.85, 3.14159 * 0.5, false, paint);

    // Green arc (bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.15, 3.14159 * 0.7, false, paint);

    // Blue arc (right-ish)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.15, 3.14159 * 0.3, false, paint);

    // Horizontal bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - paint.strokeWidth / 2,
        radius,
        paint.strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppleLogoPainter extends CustomPainter {
  const AppleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final double w = size.width;
    final double h = size.height;

    // Body (two ovals overlapped)
    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.42, h * 0.6), paint);
    canvas.drawOval(Rect.fromLTWH(w * 0.43, h * 0.25, w * 0.42, h * 0.6), paint);

    // Bottom indent (small white oval covering the bottom seam)
    final Paint cutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.78, w * 0.16, h * 0.1), cutPaint);

    // Top indent (small white oval covering the top seam)
    canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.18, w * 0.16, h * 0.1), cutPaint);

    // Leaf
    final Path leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.22);
    leafPath.quadraticBezierTo(w * 0.58, h * 0.05, w * 0.72, h * 0.08);
    leafPath.quadraticBezierTo(w * 0.66, h * 0.22, w * 0.5, h * 0.22);
    canvas.drawPath(leafPath, paint);

    // Bite
    canvas.drawCircle(Offset(w * 0.85, h * 0.45), w * 0.18, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
