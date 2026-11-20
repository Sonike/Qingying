import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/rcmd_source.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/common/common_controller.dart'
    show RefreshImplMixin;
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

class RcmdController extends CommonListController with RefreshImplMixin {
  late bool enableSaveLastData = Pref.enableSaveLastData;

  /// 可在设置页切换后立即生效，无需重启
  RcmdSource rcmdSource = Pref.rcmdSource;

  Future<void>? _activeQuery;
  int _nextFeedPage = 0;
  int? lastRefreshAt;
  late bool savedRcmdTip = Pref.savedRcmdTip;

  @override
  bool get isEnd => false;

  @override
  void onInit() {
    super.onInit();
    page = 0;
    queryData();
  }

  @override
  Future<LoadingState<List<BaseRcmdVideoItemModel>>> customGetData() async {
    var cursor = page == 0 ? 0 : _nextFeedPage;
    final source = rcmdSource;
    final items = <BaseRcmdVideoItemModel>[];
    final seen = <String>{};
    // 尤其在横屏平板上，少量保留下来的卡片可能不足以填满首屏。
    for (var request = 0; request < 3 && items.length < 6; request++) {
      final result = await fetchPage(source, cursor);
      if (result is! Success<List<BaseRcmdVideoItemModel>>) {
        if (items.isEmpty) return result;
        break;
      }
      cursor++;
      for (final item in result.response) {
        if (item.bvid == null || seen.add(item.bvid!)) items.add(item);
      }
    }
    _nextFeedPage = cursor;
    return Success(items);
  }

  Future<LoadingState<List<BaseRcmdVideoItemModel>>> fetchPage(
    RcmdSource source,
    int cursor,
  ) {
    return switch (source) {
      RcmdSource.app => VideoHttp.rcmdVideoListApp(freshIdx: cursor),
      // 桌面端：与官方 Windows 客户端一致，每次请求 30 条
      RcmdSource.desktop => VideoHttp.rcmdVideoList(
        freshIdx: cursor,
        ps: 30,
        desktop: true,
      ),
      RcmdSource.web => VideoHttp.rcmdVideoList(freshIdx: cursor, ps: 20),
    };
  }

  @override
  bool handleError(String? errMsg) {
    return enableSaveLastData &&
        loadingState.value.dataOrNull?.isNotEmpty == true;
  }

  @override
  void handleListResponse(List dataList) {
    if (enableSaveLastData && page == 0) {
      if (loadingState.value case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          if (savedRcmdTip) {
            lastRefreshAt = dataList.length;
          }
          if (response.length > 200) {
            dataList.addAll(response.take(50));
          } else {
            dataList.addAll(response);
          }
        }
      }
    }
  }

  @override
  Future<void> queryData([bool isRefresh = true]) {
    return _activeQuery ??= super.queryData(isRefresh).whenComplete(() {
      isLoading = false;
      _activeQuery = null;
    });
  }

  @override
  Future<void> onRefresh() async {
    final pending = _activeQuery;
    if (pending != null) await pending;
    if (isClosed || _activeQuery != null) return;
    page = 0;
    isEnd = false;
    return queryData();
  }

  void toTopAndRefresh() {
    scrollController.jumpToTop();
    showRefresh();
  }
}
