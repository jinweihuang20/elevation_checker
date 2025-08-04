import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassDisplay extends StatefulWidget {
  const CompassDisplay({super.key});

  @override
  State<CompassDisplay> createState() => _CompassDisplayState();
}

class _CompassDisplayState extends State<CompassDisplay> {
  double? _direction;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _direction = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_direction == null)
            const Text('設備不支援羅盤功能或未授予權限')
          else
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: CustomPaint(
                    painter: CompassPainter(direction: _direction!),
                  ),
                ),
                Transform.rotate(
                  angle: ((_direction ?? 0) * (pi / 180) * -1),
                  child: const Icon(
                    Icons.navigation,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            '方位: ${_direction?.toStringAsFixed(1)}°',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final double direction;

  CompassPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 使用 Paint 物件來繪製圓形背景
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // 繪製主要方位點
    final directions = ['N', 'E', 'S', 'W'];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - direction) * (pi / 180);
      final offset = Offset(
        center.dx + cos(angle) * (radius - 20),
        center.dy + sin(angle) * (radius - 20),
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        offset.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) {
    return oldDelegate.direction != direction;
  }
}
