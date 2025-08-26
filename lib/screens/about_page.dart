import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/about_model.dart';
import '../services/about_service.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/blinking_background.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  AboutModel? _aboutModel;
  late AnimationController _lightModeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAboutContent();
  }

  void _initializeAnimations() {
    _lightModeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _floatingAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _lightModeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _lightModeController, curve: Curves.easeInOut),
    );

    _lightModeController.repeat(reverse: true);
  }

  Future<void> _loadAboutContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await AboutService.getAboutContent();
      if (mounted) {
        setState(() {
          _aboutModel = content;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading about content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _lightModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About Me')),
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.position;
          });
        },
        child: Stack(
          children: [
            if (isDarkMode)
              const Positioned.fill(child: BlinkingDotsBackground())
            else
              _buildLightModeBackground(),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _aboutModel == null
                ? const Center(child: Text('No content available.'))
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            bool isDesktop = constraints.maxWidth > 600;
                            return isDesktop
                                ? _buildDesktopLayout(isDarkMode)
                                : _buildMobileLayout(isDarkMode);
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightModeBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _lightModeController,
        builder: (context, child) {
          return CustomPaint(
            painter: _LightModeBackgroundPainter(
              animationValue: _lightModeController.value,
              mousePosition: _mousePosition,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_aboutModel!.profilePictureUrl != null)
          AnimatedBuilder(
            animation: _lightModeController,
            builder: (context, child) {
              return Transform.translate(
                offset: isDarkMode
                    ? Offset.zero
                    : Offset(0, _floatingAnimation.value),
                child: Transform.scale(
                  scale: isDarkMode ? 1.0 : _pulseAnimation.value,
                  child: ScaleUpAnimation(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isDarkMode
                            ? null
                            : [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                      ),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: NetworkImage(
                          _aboutModel!.profilePictureUrl!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(width: 40),
        Expanded(
          child: FadeInSlideUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedTitle(isDarkMode),
                const SizedBox(height: 16),
                _buildAnimatedMarkdown(isDarkMode),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_aboutModel!.profilePictureUrl != null)
          AnimatedBuilder(
            animation: _lightModeController,
            builder: (context, child) {
              return Transform.translate(
                offset: isDarkMode
                    ? Offset.zero
                    : Offset(0, _floatingAnimation.value),
                child: Transform.scale(
                  scale: isDarkMode ? 1.0 : _pulseAnimation.value,
                  child: ScaleUpAnimation(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isDarkMode
                            ? null
                            : [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(
                          _aboutModel!.profilePictureUrl!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
        FadeInSlideUp(
          delay: const Duration(milliseconds: 200),
          child: _buildAnimatedMarkdown(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildAnimatedTitle(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _lightModeController,
      builder: (context, child) {
        return Transform.translate(
          offset: isDarkMode
              ? Offset.zero
              : Offset(_floatingAnimation.value * 0.5, 0),
          child: Text(
            'Hello!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              shadows: isDarkMode
                  ? null
                  : [
                      Shadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMarkdown(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _lightModeController,
      builder: (context, child) {
        return Container(
          decoration: isDarkMode
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10 + (_pulseAnimation.value - 1) * 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
          child: MarkdownBody(
            data: _aboutModel!.content,
            extensionSet: md.ExtensionSet.gitHubWeb,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(
                  p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                  ),
                  h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                  h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
                  blockquotePadding: const EdgeInsets.all(16),
                ),
          ),
        );
      },
    );
  }
}

class _LightModeBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Offset mousePosition;

  _LightModeBackgroundPainter({
    required this.animationValue,
    required this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(Colors.blue[50], Colors.purple[50], animationValue)!,
        Color.lerp(Colors.pink[50], Colors.orange[50], animationValue)!,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    for (int i = 0; i < 5; i++) {
      final x =
          (sin(animationValue * 2 * pi + i * 2) * size.width * 0.4) +
          (size.width * 0.5);
      final y =
          (cos(animationValue * 2 * pi + i * 3) * size.height * 0.4) +
          (size.height * 0.5);
      final radius = 50 + (sin(animationValue * 2 * pi + i) * 20);

      final distance = (Offset(x, y) - mousePosition).distance;
      final proximity = 1 - (distance / 300).clamp(0.0, 1.0);

      final orbColor = Color.lerp(
        Colors.white.withOpacity(0.5),
        Colors.purple.withOpacity(0.3),
        (i / 5.0) + proximity * 0.5,
      )!;

      final orbPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            orbColor.withOpacity(0.1 + proximity * 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(Offset(x, y), radius, orbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
