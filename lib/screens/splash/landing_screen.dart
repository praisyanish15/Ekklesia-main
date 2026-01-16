import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1929), // Midnight Blue
              Color(0xFF081422),
              Color(0xFF050A12),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  children: [
                    // Logo and Branding
                    _buildHeader(),
                    const SizedBox(height: 60),

                    // Tagline
                    _buildTagline(),
                    const SizedBox(height: 60),

                    // Feature Grid
                    _buildFeatureGrid(context),
                    const SizedBox(height: 40),

                    // Get Started Button
                    _buildGetStartedButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Golden Crescent Logo
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A574).withOpacity(0.3), // Soft Gold glow
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Crescent
            CustomPaint(
              size: const Size(80, 80),
              painter: CrescentPainter(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // EKKLESIA Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE8B88B), Color(0xFFD4A574), Color(0xFFB8956A)], // Soft Gold gradient
          ).createShader(bounds),
          child: Text(
            'EKKLESIA',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      'From Call... to Gathering',
      style: GoogleFonts.cormorantGaramond(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: const Color(0xFFD4A574), // Soft Gold
        letterSpacing: 2,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {
        'title': 'Not a fad. A gathering.',
        'icon': Icons.light_mode,
        'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
      },
      {
        'title': 'Be still.',
        'icon': Icons.circle_outlined,
        'gradient': [Color(0xFFD4AF37), Color(0xFFFFD700)],
      },
      {
        'title': 'The Word meets you.',
        'icon': Icons.menu_book,
        'gradient': [Color(0xFFFFA500), Color(0xFFD4AF37)],
      },
      {
        'title': 'You are not alone.',
        'icon': Icons.star_border,
        'gradient': [Color(0xFFFFD700), Color(0xFFD4AF37)],
      },
      {
        'title': 'Worship expands to presence.',
        'icon': Icons.auto_awesome,
        'gradient': [Color(0xFFD4AF37), Color(0xFFFFA500)],
      },
      {
        'title': 'Find far-fro peace.',
        'icon': Icons.local_fire_department_outlined,
        'gradient': [Color(0xFFFFA500), Color(0xFFFFD700)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _FeatureCard(
          title: feature['title'] as String,
          icon: feature['icon'] as IconData,
          gradient: feature['gradient'] as List<Color>,
        );
      },
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(
              'Enter the Gathering',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0E27),
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1535).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.gradient[0].withOpacity(0.6)
                : const Color(0xFF1A1F3A).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.gradient[0].withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: widget.gradient,
                    ).createShader(bounds),
                    child: Icon(
                      widget.icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB8B8B8),
                  height: 1.4,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8B88B), Color(0xFFD4A574)], // Soft Gold gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw crescent moon shape
    final path = Path();

    // Outer arc (right side of moon)
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
    );

    // Inner arc (creates crescent)
    final innerCenter = Offset(center.dx + radius * 0.3, center.dy);
    path.arcTo(
      Rect.fromCircle(center: innerCenter, radius: radius * 0.8),
      math.pi / 2,
      -math.pi,
      false,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
