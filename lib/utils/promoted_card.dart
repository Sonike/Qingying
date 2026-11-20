/// 仅使用推荐接口的结构化商业标识，忽略标题、作者和推荐文案。
bool isPromotedCard(Map<String, dynamic> card) {
  if (card['ad_info'] != null) return true;
  if (card['is_ad'] case true || 1 || '1') {
    return true;
  }
  for (final key in const ['card_goto', 'goto', 'card_type']) {
    final type = card[key];
    if (type is String && (type == 'ad' || type.startsWith('ad_'))) {
      return true;
    }
  }
  return false;
}
