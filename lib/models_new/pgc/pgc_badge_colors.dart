import 'dart:ui' show Brightness, Color;

/// Backgrounds supplied with a season's badge. Older responses only have a label.
class PgcBadgeColors {
  const PgcBadgeColors({this.day, this.night});

  final Color? day;
  final Color? night;

  factory PgcBadgeColors.fromJson(Object? value) {
    if (value is! Map) return const PgcBadgeColors();
    return PgcBadgeColors(
      day: _parse(value['bg_color']),
      night: _parse(value['bg_color_night']),
    );
  }

  static Color? _parse(Object? value) {
    if (value is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
      return null;
    }
    return Color(0xFF000000 | int.parse(value.substring(1), radix: 16));
  }

  Color resolve(String? label, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final supplied = dark ? night ?? day : day ?? night;
    if (supplied != null) return supplied;
    return switch (label) {
      '出品' || '独家' || '独播' => Color(dark ? 0xFF0B91BE : 0xFF00C0FF),
      '大会员' || '会员' || '会员专享' => Color(dark ? 0xFFD44E7D : 0xFFFB7299),
      _ => Color(dark ? 0xFF61666D : 0xFF797F87),
    };
  }
}
