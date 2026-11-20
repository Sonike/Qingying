import 'package:PiliPlus/utils/promoted_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters explicit commercial fields on app and web cards', () {
    for (final card in <Map<String, dynamic>>[
      {
        'goto': 'av',
        'ad_info': {'id': 123},
      },
      {'goto': 'ad_web_s'},
      {'card_goto': 'ad_av'},
      {'card_type': 'ad_banner'},
      {'card_goto': 'ad'},
      for (final flag in [true, 1, '1']) {'goto': 'av', 'is_ad': flag},
    ]) {
      expect(isPromotedCard(card), isTrue, reason: card.toString());
    }
  });

  test('preserves regular and followed videos about commercial topics', () {
    for (final flag in [null, false, 0, '0']) {
      expect(
        isPromotedCard({
          'card_goto': 'av',
          'goto': 'av',
          'card_type': 'small_cover_v2',
          'ad_info': null,
          'is_ad': flag,
          'is_followed': 1,
          'title': '广告设计公开课',
          'rcmd_reason': '已关注',
        }),
        isFalse,
      );
    }
  });
}
