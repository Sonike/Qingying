import 'dart:math' as math;

import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:material_ui/material_ui.dart';

class FeedNavIcon extends StatelessWidget {
  const FeedNavIcon(this.tab, {super.key});

  final NavigationBarType tab;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final scheme = ColorScheme.of(context);
    return CustomPaint(
      size: Size.square(theme.size ?? 24),
      painter: _TabPainter(tab, theme.color ?? scheme.onSurfaceVariant),
    );
  }
}

class _TabPainter extends CustomPainter {
  const _TabPainter(this.tab, this.color);
  final NavigationBarType tab;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.05;
    switch (tab) {
      case NavigationBarType.home:
        canvas
          ..drawPath(
            Path()
              ..moveTo(2.1, 10.8)
              ..lineTo(12, 2.4)
              ..lineTo(21.9, 10.8),
            pen,
          )
          ..drawPath(
            Path()
              ..moveTo(19.4, 9.2)
              ..lineTo(19.4, 17.5)
              ..quadraticBezierTo(19.4, 21.9, 15.2, 21.9)
              ..lineTo(8.5, 21.9)
              ..quadraticBezierTo(4.6, 21.9, 4.6, 17.8)
              ..lineTo(4.6, 12.8),
            pen,
          )
          ..drawPath(
            Path()
              ..moveTo(9.5, 17)
              ..quadraticBezierTo(12, 20.2, 14.5, 17),
            pen..strokeWidth = 1.6,
          );
      case NavigationBarType.dynamics:
        // Each vane is a half-disc that meets the next at the centre.
        final vane = Path()
          ..moveTo(12, 12)
          ..lineTo(12, 1.9)
          ..cubicTo(5.4, 1.9, 5.4, 12, 12, 12)
          ..close();
        canvas.save();
        for (int i = 0; i < 4; i++) {
          canvas
            ..drawPath(vane, pen)
            ..translate(12, 12)
            ..rotate(math.pi / 2)
            ..translate(-12, -12);
        }
        canvas.restore();
      case NavigationBarType.mine:
        canvas
          ..drawLine(
            const Offset(5.5, 2.5),
            const Offset(9.2, 6.2),
            pen..strokeWidth = 1.55,
          )
          ..drawLine(const Offset(18.4, 2.5), const Offset(14.7, 6.2), pen)
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTRB(1.9, 6.4, 22.1, 22),
              const Radius.circular(4.2),
            ),
            pen..strokeWidth = 2.05,
          )
          ..drawLine(
            const Offset(5.7, 14),
            const Offset(10, 14),
            pen..strokeWidth = 1.65,
          )
          ..drawLine(const Offset(14, 14), const Offset(18.3, 14), pen);
    }
  }

  @override
  bool shouldRepaint(_TabPainter old) => tab != old.tab || color != old.color;
}
