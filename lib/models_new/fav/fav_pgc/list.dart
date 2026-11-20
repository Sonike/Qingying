import 'package:PiliPlus/models_new/pgc/pgc_badge_colors.dart';
import 'package:PiliPlus/models_new/fav/fav_pgc/new_ep.dart';
import 'package:PiliPlus/pages/common/multi_select/base.dart';

class FavPgcItemModel with MultiSelectData {
  int? seasonId;
  String? title;
  String? cover;
  int? isFinish;
  String? badge;
  final PgcBadgeColors badgeColors;
  NewEp? newEp;
  String? renewalTime;
  String? progress;

  FavPgcItemModel({
    this.seasonId,
    this.title,
    this.cover,
    this.isFinish,
    this.badge,
    this.badgeColors = const PgcBadgeColors(),
    this.newEp,
    this.renewalTime,
    this.progress,
  });

  factory FavPgcItemModel.fromJson(
    Map<String, dynamic> json,
  ) => FavPgcItemModel(
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
    cover: json['cover'] as String?,
    isFinish: json['is_finish'] as int?,
    badge: json['badge'] as String?,
    badgeColors: PgcBadgeColors.fromJson(json['badge_info']),
    newEp: json['new_ep'] == null
        ? null
        : NewEp.fromJson(json['new_ep'] as Map<String, dynamic>),
    renewalTime: json['renewal_time'] as String?,
    progress: json['progress'] == '' ? null : json['progress'],
  );
}
