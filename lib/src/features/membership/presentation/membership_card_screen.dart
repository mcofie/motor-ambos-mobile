import 'dart:math' as math;
import 'package:flutter/material.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock Data
    const userName = 'Maxwell Cofie';
    const membershipTier = 'PREMIUM';
    const membershipId = 'MBR 8821 9004';
    final expiryDate = DateTime.now().add(const Duration(days: 142));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Digital Card',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),

          // 1. The Flippable Card Area
          Center(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calculate rotation angle
                  final angle = _animation.value * math.pi;
                  final isBack = angle >= (math.pi / 2);

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isBack
                        ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(math.pi), // Mirror back
                      child: const _CardBack(),
                    )
                        : _CardFront(
                      userName: userName,
                      tier: membershipTier,
                      id: membershipId,
                      expiryDate: expiryDate,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 2. Instructions
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isFront
                  ? 'Tap card to view QR code'
                  : 'Tap card to view details',
              key: ValueKey(_isFront),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),

          // 3. Wallet Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Membership Active',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Apple Wallet')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      // Adaptive: Black in Light Mode, White in Dark Mode
                      backgroundColor: colorScheme.onSurface,
                      foregroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.wallet),
                    label: const Text("Add to Apple Wallet"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// FRONT OF CARD
//
class _CardFront extends StatelessWidget {
  final String userName;
  final String tier;
  final String id;
  final DateTime expiryDate;

  const _CardFront({
    required this.userName,
    required this.tier,
    required this.id,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final expiryText =
        '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';

    // NOTE: We keep specific dark colors for the card front even in Light Mode
    // to maintain the "Premium Black Card" brand identity.
    const cardColorStart = Color(0xFF2C2C2C);
    const cardColorEnd = Colors.black;

    return Container(
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColorStart, cardColorEnd],
        ),
      ),
      child: Stack(
        children: [
          // Decorative Abstract Shape
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MotorAmbos',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Text(
                        tier,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Chip + ID
                Row(
                  children: [
                    // Fake EMV Chip
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37), // Gold
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFBE18A), Color(0xFFD4AF37)],
                        ),
                      ),
                      child: CustomPaint(painter: _ChipPainter()),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      id,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Footer: Name & Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMBER NAME',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 8,
                          ),
                        ),
                        Text(
                          userName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VALID THRU',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 8,
                          ),
                        ),
                        Text(
                          expiryText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// BACK OF CARD
//
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // Adaptive BG
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Magnetic Strip
          Container(
            height: 40,
            width: double.infinity,
            color: const Color(0xFF1a1a1a), // Always dark
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // QR Code Area
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colorScheme.onSurface,
                              width: 4
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Using Icon as placeholder for QR Image
                        child: Icon(
                          Icons.qr_code_2,
                          size: 80,
                          // In Dark Mode, QR code becomes white
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Instructions
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SCAN TO VERIFY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Show this code at partner locations for discounts.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Support: +233 20 000 0000',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Painter to draw lines on the fake chip
class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final w = size.width;
    final h = size.height;

    // Draw some techy lines
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), paint);
    canvas.drawLine(Offset(w * 0.7, 0), Offset(w * 0.7, h), paint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), paint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * 0.3,
        height: h * 0.4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}