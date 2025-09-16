// In-Class Activity 04 – Drawing with Flutter
// Team Members: Melkamu Gebre & Samuel Birhan

import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Drawing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const DrawingHome(),
    );
  }
}

enum EmojiType { smiley, party, heart }

class EmojiStamp {
  final Offset pos;
  final EmojiType type;
  final double size;
  const EmojiStamp(this.pos, this.type, this.size);
}

class DrawingHome extends StatefulWidget {
  const DrawingHome({super.key});
  @override
  State<DrawingHome> createState() => _DrawingHomeState();
}

class _DrawingHomeState extends State<DrawingHome> {
  EmojiType _emoji = EmojiType.party;
  bool _gradientBg = true;
  bool _dragMode = true;
  double _stampSize = 56;

  final List<EmojiStamp> _stamps = [];

  void _addStamp(Offset p) {
    setState(() => _stamps.add(EmojiStamp(p, _emoji, _stampSize)));
  }

  void _onTapDown(TapDownDetails d, Size size) {
    if (d.localPosition.dy < size.height - 120) _addStamp(d.localPosition);
  }

  void _onPanStart(DragStartDetails d, Size size) {
    if (!_dragMode) return;
    if (d.localPosition.dy < size.height - 120) _addStamp(d.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (!_dragMode) return;
    if (d.localPosition.dy < size.height - 120) _addStamp(d.localPosition);
  }

  void _undo() {
    if (_stamps.isNotEmpty) setState(() => _stamps.removeLast());
  }

  void _clear() => setState(() => _stamps.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji Drawing'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Undo',
            onPressed: _stamps.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: _stamps.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final canvasSize = Size(
            constraints.maxWidth,
            constraints.maxHeight - kToolbarHeight,
          );

          return Column(
            children: [
              // Top controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Emoji picker
                    SegmentedButton<EmojiType>(
                      style: ButtonStyle(
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                      ),
                      multiSelectionEnabled: false,
                      segments: const [
                        ButtonSegment(
                          value: EmojiType.smiley, icon: Icon(Icons.tag_faces), label: Text('Smiley'),
                        ),
                        ButtonSegment(
                          value: EmojiType.party, icon: Icon(Icons.celebration), label: Text('Party'),
                        ),
                        ButtonSegment(
                          value: EmojiType.heart, icon: Icon(Icons.favorite), label: Text('Heart'),
                        ),
                      ],
                      selected: {_emoji},
                      onSelectionChanged: (s) => setState(() => _emoji = s.first),
                    ),
                    const SizedBox(width: 12),
                    // Size slider
                    Flexible(
                      child: Row(
                        children: [
                          const Text('Size'),
                          Expanded(
                            child: Slider(
                              min: 32, max: 120,
                              value: _stampSize,
                              onChanged: (v) => setState(() => _stampSize = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Drag toggle
                    Row(
                      children: [
                        const Text('Drag'),
                        Switch(
                          value: _dragMode,
                          onChanged: (v) => setState(() => _dragMode = v),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Gradient toggle
                    Row(
                      children: [
                        const Text('Gradient'),
                        Switch(
                          value: _gradientBg,
                          onChanged: (v) => setState(() => _gradientBg = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Canvas (interactive)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _onTapDown(d, canvasSize),
                  onPanStart: (d) => _onPanStart(d, canvasSize),
                  onPanUpdate: (d) => _onPanUpdate(d, canvasSize),
                  child: CustomPaint(
                    painter: EmojiPainter(
                      stamps: _stamps,
                      gradientBg: _gradientBg,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

              // Task 1: Basic shapes row (square, circle, arc), as a footer strip
              SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: BasicShapesPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Footer strip — Task 1
class BasicShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final w = size.width;

    // Soft bg
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.indigo.withOpacity(0.04),
    );

    // Square
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.2, centerY), width: 62, height: 62),
      Paint()..color = Colors.blue,
    );

    // Circle
    canvas.drawCircle(
      Offset(w * 0.5, centerY),
      32,
      Paint()..color = Colors.red,
    );

    // Arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.8, centerY), width: 86, height: 86),
      -pi / 2,
      pi * 1.25,
      false,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Main painter for all stamps + background.
class EmojiPainter extends CustomPainter {
  EmojiPainter({
    required this.stamps,
    required this.gradientBg,
  });

  final bool gradientBg;
  final List<EmojiStamp> stamps;

  @override
  void paint(Canvas canvas, Size size) {
    // Background (subtle gradient)
    if (gradientBg) {
      final rect = Offset.zero & size;
      final shader = LinearGradient(
        colors: [Colors.indigo.shade50, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
      canvas.drawRect(rect, Paint()..shader = shader);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    }

    if (stamps.isEmpty) {
      final center = Offset(size.width / 2, size.height / 2 - 36);
      _drawHint(canvas, center);
      return;
    }

    // Draw in order of creation
    for (final s in stamps) {
      switch (s.type) {
        case EmojiType.smiley:
          _drawSmiley(canvas, s.pos, s.size);
          break;
        case EmojiType.party:
          _drawPartyFace(canvas, s.pos, s.size);
          break;
        case EmojiType.heart:
          _drawHeart(canvas, s.pos, s.size * 1.1);
          break;
      }
    }
  }

  void _drawHint(Canvas c, Offset center) {
    // Soft glow circle
    c.drawCircle(center, 90, Paint()..color = Colors.indigo.withOpacity(0.06));
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Tap or drag on the canvas',
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  // Smiley with glow + proper arc smile
  void _drawSmiley(Canvas c, Offset center, double r) {
    // Glow (fake shadow)
    c.drawCircle(center + const Offset(0, 2), r * 1.05,
        Paint()..color = Colors.black.withOpacity(0.06));

    // Face fill
    c.drawCircle(center, r, Paint()..color = const Color(0xFFFFE066));

    // Eyes
    final eye = Paint()..color = Colors.black;
    c.drawCircle(center + Offset(-r * 0.35, -r * 0.28), r * 0.12, eye);
    c.drawCircle(center + Offset( r * 0.35, -r * 0.28), r * 0.12, eye);

    // Smile
    final rect =
        Rect.fromCircle(center: center + Offset(0, r * 0.06), radius: r * 0.58);
    final smile = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.5, r * 0.12)
      ..strokeCap = StrokeCap.round;
    c.drawArc(rect, pi * 0.15, pi * 0.75, false, smile);

    // Shine
    c.drawCircle(center + Offset(-r * 0.44, -r * 0.44),
        r * 0.11, Paint()..color = Colors.white.withOpacity(0.5));
  }

  // Party face: reuse smiley, then hat + confetti positioned correctly
  void _drawPartyFace(Canvas c, Offset center, double r) {
    _drawSmiley(c, center, r);

    // Party hat above the circle
    final top = center + Offset(0, -r * 1.15);
    final left = center + Offset(-r * 0.62, -r * 0.20);
    final right = center + Offset( r * 0.62, -r * 0.20);
    final hat = Path()..moveTo(top.dx, top.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close();

    final hatPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hat.getBounds());
    c.drawPath(hat, hatPaint);

    // Confetti around face (evenly distributed with noise)
    final rnd = Random((center.dx + center.dy).floor());
    final confettiCount = max(10, (r / 6).round());
    for (int i = 0; i < confettiCount; i++) {
      final theta = (i / confettiCount) * 2 * pi + rnd.nextDouble() * .2;
      final dist = r * (0.95 + rnd.nextDouble() * 0.7);
      final p = center + Offset(cos(theta) * dist, sin(theta) * dist);

      final paint = Paint()
        ..color = [
          Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.pink, Colors.teal
        ][rnd.nextInt(6)];

      final s = r * 0.10;
      switch (rnd.nextInt(3)) {
        case 0: c.drawCircle(p, s * 0.40, paint); break;
        case 1: c.drawRect(Rect.fromCenter(center: p, width: s * .6, height: s * .45), paint); break;
        default:
          final tri = Path()
            ..moveTo(p.dx, p.dy - s * .4)
            ..lineTo(p.dx - s * .35, p.dy + s * .3)
            ..lineTo(p.dx + s * .35, p.dy + s * .3)
            ..close();
          c.drawPath(tri, paint);
      }
    }
  }

  // Heart with gradient fill + border
  void _drawHeart(Canvas c, Offset center, double size) {
    final s = size / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy + s * 0.65)
      ..cubicTo(
        center.dx - s * 1.25, center.dy - s * 0.1,
        center.dx - s * 0.8,  center.dy - s * 1.2,
        center.dx,            center.dy - s * 0.35,
      )
      ..cubicTo(
        center.dx + s * 0.8,  center.dy - s * 1.2,
        center.dx + s * 1.25, center.dy - s * 0.1,
        center.dx,            center.dy + s * 0.65,
      );

    // Glow
    c.drawPath(
      path,
      Paint()
        ..color = Colors.red.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Fill
    final fill = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red, Colors.pinkAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: center, width: size, height: size));
    c.drawPath(path, fill);

    // Border
    c.drawPath(
      path,
      Paint()
        ..color = Colors.red.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2, size * 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant EmojiPainter old) =>
      old.gradientBg != gradientBg || old.stamps != stamps;
}