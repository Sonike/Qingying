import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/common/widgets/video_popup_menu.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models_new/video/video_detail/dimension.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/extension/dimension_ext.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

// 视频卡片 - 垂直布局
class VideoCardV extends StatelessWidget {
  final BaseRcmdVideoItemModel videoItem;
  final VoidCallback? onRemove;

  const VideoCardV({
    super.key,
    required this.videoItem,
    this.onRemove,
  });

  Future<void> onPushDetail() async {
    switch (videoItem.goto) {
      case 'bangumi':
        PageUtils.viewPgc(epId: videoItem.param!);
        break;
      case 'av':
        var bvid = videoItem.bvid ?? IdUtils.av2bv(videoItem.aid!);
        var cid = videoItem.cid;
        bool isVertical = false;
        Dimension? dimension;
        if (videoItem is RcmdVideoItemAppModel) {
          if (videoItem.uri case final uri?) {
            isVertical = uri.isVerticalFromUri;
          }
        }
        if (cid == null) {
          if (await SearchHttp.ab2cWithDimension(aid: videoItem.aid, bvid: bvid)
              case final res?) {
            cid = res.cid;
            dimension = res.dimension;
          }
        }
        if (cid != null) {
          PageUtils.toVideoPage(
            aid: videoItem.aid,
            bvid: bvid,
            cid: cid,
            cover: videoItem.cover,
            title: videoItem.title,
            isVertical: isVertical,
            dimension: dimension,
          );
        }
        break;
      // 动态
      case 'picture':
        try {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;
      default:
        if (videoItem.uri?.isNotEmpty == true) {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    void onLongPress() => imageSaveDialog(
      title: videoItem.title,
      cover: videoItem.cover,
      bvid: videoItem.bvid,
    );
    final colors = ColorScheme.of(context);
    final badges = [
      if (videoItem.goto == 'bangumi' && videoItem.pgcBadge != null)
        videoItem.pgcBadge!,
      if (videoItem.goto == 'picture') '动态',
      if (videoItem.isFollowed) '已关注',
      if (videoItem.rcmdReason case final reason? when reason.isNotEmpty)
        reason,
    ];
    final owner = videoItem.owner.name ?? '';
    final date = videoItem is RcmdVideoItemModel && videoItem.pubdate != null
        ? DateFormatUtils.dateFormat(
            videoItem.pubdate,
            short: shortFormat,
            long: longFormat,
          )
        : '';
    return Material(
      color: colors.surface,
      borderRadius: Style.borderRadius6,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onPushDetail,
            onLongPress: onLongPress,
            onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                AspectRatio(
                  aspectRatio: Style.aspectRatio16x9,
                  child: LayoutBuilder(
                    builder: (context, box) => Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImgLayer(
                          src: videoItem.cover,
                          width: box.maxWidth,
                          height: box.maxHeight,
                          borderRadius: .zero,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xAA000000)],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 15, 6, 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: .min,
                                        spacing: 7,
                                        children: [
                                          StatWidget(
                                            type: .play,
                                            value: videoItem.stat.view,
                                            color: Colors.white,
                                          ),
                                          if (videoItem.goto != 'picture')
                                            StatWidget(
                                              type: .danmaku,
                                              value: videoItem.stat.danmu,
                                              color: Colors.white,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (videoItem.duration > 0) ...[
                                    const SizedBox(width: 5),
                                    Text(
                                      DurationUtils.formatDuration(
                                        videoItem.duration,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: .w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 7),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Text(
                            videoItem.title,
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: videoItem.goto == 'av' ? 16 : 0,
                          ),
                          child: Row(
                            spacing: 4,
                            children: [
                              if (badges.isEmpty)
                                ExcludeSemantics(child: _upMark(colors.outline))
                              else
                                Flexible(
                                  child: Text(
                                    badges.join(' · '),
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    style: TextStyle(
                                      color: colors.onPrimaryContainer,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  date.isEmpty ? owner : '$owner · $date',
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  semanticsLabel: date.isEmpty
                                      ? 'UP：$owner'
                                      : 'UP：$owner，$date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.outline,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (videoItem.goto == 'av')
            Positioned(
              right: 0,
              bottom: 0,
              width: 28,
              height: 29,
              child: VideoPopupMenu(
                iconSize: 16,
                videoItem: videoItem,
                onRemove: onRemove,
              ),
            ),
        ],
      ),
    );
  }

  static Widget _upMark(Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: color, width: 0.8),
    ),
    child: Text(
      'UP',
      style: TextStyle(
        fontSize: 8,
        fontWeight: .w600,
        height: 1.18,
        color: color,
      ),
    ),
  );

  static final shortFormat = DateFormat('M-d');
  static final longFormat = DateFormat('yy-M-d');
}
