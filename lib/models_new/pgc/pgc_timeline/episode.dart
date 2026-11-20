class Episode {
  String? cover;
  int? episodeId;
  int? follow;
  final bool isPublished;
  String? pubIndex;
  String? pubTime;
  int? seasonId;
  String? title;

  Episode({
    this.cover,
    this.episodeId,
    this.follow,
    this.isPublished = false,
    this.pubIndex,
    this.pubTime,
    this.seasonId,
    this.title,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    cover: json['cover'] as String?,
    episodeId: json['episode_id'] as int?,
    follow: json['follow'] as int?,
    isPublished: json['published'] == 1,
    pubIndex: json['pub_index'] as String?,
    pubTime: json['pub_time'] as String?,
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
  );
}
