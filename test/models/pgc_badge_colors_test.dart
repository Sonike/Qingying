import 'dart:ui';

import 'package:PiliPlus/models_new/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models_new/pgc/pgc_index_result/list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'index and followed seasons use the provided badge colors in each mode',
    () {
      final json = {
        'badge': '独家',
        'badge_info': {'bg_color': '#17C9FF', 'bg_color_night': '#159BCB'},
      };
      final index = PgcIndexItem.fromJson(json);
      final favorite = FavPgcItemModel.fromJson(json);
      for (final colors in [index.badgeColors, favorite.badgeColors]) {
        expect(colors.resolve('独家', Brightness.light), const Color(0xFF17C9FF));
        expect(colors.resolve('独家', Brightness.dark), const Color(0xFF159BCB));
      }
    },
  );

  test('legacy badges keep their meaning when service colors are missing or malformed', () {
    final exclusive = PgcIndexItem.fromJson({'badge': '出品'});
    final member = PgcIndexItem.fromJson({
      'badge': '大会员',
      'badge_info': {'bg_color': '', 'bg_color_night': '#notrgb'},
    });
    expect(
      exclusive.badgeColors.resolve(exclusive.badge, Brightness.light),
      const Color(0xFF00C0FF),
    );
    expect(
      member.badgeColors.resolve(member.badge, Brightness.dark),
      const Color(0xFFD44E7D),
    );
  });
}
