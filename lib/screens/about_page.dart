import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/about_model.dart';
import '../services/about_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  bool _isLoading = true;
  AboutModel? _aboutModel;

  @override
  void initState() {
    super.initState();
    _loadAboutContent();
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF0A0A0A) 
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            _buildPixelMedicalIcon(isDarkMode),
            const SizedBox(width: 12),
            const Text('About Me'),
          ],
        ),
        backgroundColor: isDarkMode 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        foregroundColor: isDarkMode 
            ? Colors.white 
            : Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildMedicalBackground(isDarkMode),
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
    );
  }

  Widget _buildMedicalBackground(bool isDarkMode) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MedicalBackgroundPainter(isDarkMode: isDarkMode),
        child: Container(),
      ),
    );
  }

  Widget _buildPixelMedicalIcon(bool isDarkMode) {
    return Container(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _PixelMedicalIconPainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (_aboutModel!.profilePictureUrl != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode 
                        ? const Color(0xFF00A86B) 
                        : const Color(0xFF2E7D32),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: NetworkImage(
                    _aboutModel!.profilePictureUrl!,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _buildMedicalPixelArt(isDarkMode),
          ],
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(isDarkMode),
              const SizedBox(height: 16),
              _buildMarkdown(isDarkMode),
            ],
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode 
                    ? const Color(0xFF00A86B) 
                    : const Color(0xFF2E7D32),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(
                _aboutModel!.profilePictureUrl!,
              ),
            ),
          ),
        const SizedBox(height: 20),
        _buildMedicalPixelArt(isDarkMode),
        const SizedBox(height: 24),
        _buildMarkdown(isDarkMode),
      ],
    );
  }

  Widget _buildTitle(bool isDarkMode) {
    return Row(
      children: [
        Text(
          'Hello!',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 16),
        _buildPixelStethoscope(isDarkMode),
      ],
    );
  }

  Widget _buildMedicalPixelArt(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF00A86B) 
              : const Color(0xFF2E7D32),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPixelHeart(isDarkMode),
          const SizedBox(width: 12),
          _buildPixelPill(isDarkMode),
          const SizedBox(width: 12),
          _buildPixelSyringe(isDarkMode),
          const SizedBox(width: 12),
          _buildPixelCross(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPixelHeart(bool isDarkMode) {
    return Container(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _PixelHeartPainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildPixelPill(bool isDarkMode) {
    return Container(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _PixelPillPainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildPixelSyringe(bool isDarkMode) {
    return Container(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _PixelSyringePainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildPixelCross(bool isDarkMode) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _PixelCrossPainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildPixelStethoscope(bool isDarkMode) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _PixelStethoscopePainter(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildMarkdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: MarkdownBody(
        data: _aboutModel!.content,
        extensionSet: md.ExtensionSet.gitHubWeb,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
            .copyWith(
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.8,
                fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
              h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode 
                    ? const Color(0xFF00A86B) 
                    : const Color(0xFF2E7D32),
                backgroundColor: isDarkMode 
                    ? Colors.grey[900] 
                    : Colors.grey[100],
              ),
              h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
              h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
              blockquotePadding: const EdgeInsets.all(16),
              blockquoteDecoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isDarkMode 
                        ? const Color(0xFF00A86B) 
                        : const Color(0xFF2E7D32),
                    width: 4,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// Medical Background Painter
class _MedicalBackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  _MedicalBackgroundPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background gradient
    final gradient = isDarkMode 
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1117),
              const Color(0xFF1A1A1A),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FA),
              const Color(0xFFE8F5E8),
            ],
          );

    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw subtle medical crosses pattern
    final crossPaint = Paint()
      ..color = (isDarkMode 
          ? const Color(0xFF00A86B) 
          : const Color(0xFF2E7D32)).withValues(alpha: 0.05);

    for (int x = 0; x < size.width; x += 100) {
      for (int y = 0; y < size.height; y += 100) {
        _drawPixelCross(canvas, crossPaint, Offset(x + 50, y + 50), 8);
      }
    }
  }

  void _drawPixelCross(Canvas canvas, Paint paint, Offset center, double size) {
    final pixelSize = size / 8;
    
    // Vertical line
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - pixelSize,
        center.dy - size / 2,
        pixelSize * 2,
        size,
      ),
      paint,
    );
    
    // Horizontal line
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - size / 2,
        center.dy - pixelSize,
        size,
        pixelSize * 2,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pixel Art Painters
class _PixelMedicalIconPainter extends CustomPainter {
  final bool isDarkMode;

  _PixelMedicalIconPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode 
          ? const Color(0xFF00A86B) 
          : const Color(0xFF2E7D32);

    final pixelSize = size.width / 8;

    // Draw a simple medical cross
    // Vertical line
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 3, pixelSize, pixelSize * 2, pixelSize * 6),
      paint,
    );
    
    // Horizontal line
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, pixelSize * 3, pixelSize * 6, pixelSize * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelHeartPainter extends CustomPainter {
  final bool isDarkMode;

  _PixelHeartPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[400]!;

    final pixelSize = size.width / 8;
    
    // Heart shape using pixels
    final heartPixels = [
      [0, 2], [0, 3], [1, 1], [1, 2], [1, 3], [1, 4],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5],
      [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6],
      [4, 2], [4, 3], [4, 4], [4, 5], [4, 6],
      [5, 3], [5, 4], [5, 5], [5, 6],
      [6, 4], [6, 5], [7, 5],
      // Right side
      [0, 5], [0, 6], [1, 4], [1, 5], [1, 6], [1, 7],
      [2, 5], [2, 6], [2, 7], [2, 8],
    ];

    for (final pixel in heartPixels) {
      if (pixel[0] < 8 && pixel[1] < 8) {
        canvas.drawRect(
          Rect.fromLTWH(
            pixel[1] * pixelSize,
            pixel[0] * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelPillPainter extends CustomPainter {
  final bool isDarkMode;

  _PixelPillPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.blue[400]!;
    final paint2 = Paint()..color = Colors.orange[400]!;

    final pixelSize = size.width / 8;

    // Left half (blue)
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, pixelSize * 2, pixelSize * 3, pixelSize * 4),
      paint1,
    );

    // Right half (orange)
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 4, pixelSize * 2, pixelSize * 3, pixelSize * 4),
      paint2,
    );

    // Rounded ends
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 2, pixelSize, pixelSize, pixelSize),
      paint1,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 2, pixelSize * 6, pixelSize, pixelSize),
      paint1,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 5, pixelSize, pixelSize, pixelSize),
      paint2,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 5, pixelSize * 6, pixelSize, pixelSize),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelSyringePainter extends CustomPainter {
  final bool isDarkMode;

  _PixelSyringePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = Colors.grey[300]!;
    final needlePaint = Paint()..color = Colors.grey[600]!;
    final liquidPaint = Paint()..color = Colors.cyan[300]!;

    final pixelSize = size.width / 8;

    // Syringe body
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 2, pixelSize * 2, pixelSize * 3, pixelSize * 4),
      bodyPaint,
    );

    // Liquid inside
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 2.5, pixelSize * 3, pixelSize * 2, pixelSize * 2),
      liquidPaint,
    );

    // Needle
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 5, pixelSize * 3.5, pixelSize * 2, pixelSize),
      needlePaint,
    );

    // Plunger
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, pixelSize * 3.5, pixelSize, pixelSize),
      needlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelCrossPainter extends CustomPainter {
  final bool isDarkMode;

  _PixelCrossPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode 
          ? const Color(0xFF00A86B) 
          : const Color(0xFF2E7D32);

    final pixelSize = size.width / 8;

    // Vertical line
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 3, pixelSize, pixelSize * 2, pixelSize * 6),
      paint,
    );
    
    // Horizontal line
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, pixelSize * 3, pixelSize * 6, pixelSize * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelStethoscopePainter extends CustomPainter {
  final bool isDarkMode;

  _PixelStethoscopePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;

    final pixelSize = size.width / 10;

    // Stethoscope tubing (curved)
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 2, pixelSize * 2, pixelSize, pixelSize * 6),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 7, pixelSize * 2, pixelSize, pixelSize * 6),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 3, pixelSize * 7, pixelSize * 4, pixelSize),
      paint,
    );

    // Chest piece
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 4, pixelSize * 8, pixelSize * 2, pixelSize),
      paint,
    );

    // Earpieces
    canvas.drawRect(
      Rect.fromLTWH(pixelSize, pixelSize, pixelSize * 2, pixelSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(pixelSize * 7, pixelSize, pixelSize * 2, pixelSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
