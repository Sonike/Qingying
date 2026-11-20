import 'dart:io';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/rcmd_source.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/pages/rcmd/controller.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

class _Video extends BaseRcmdVideoItemModel {
  _Video(String id) {
    bvid = id;
  }
}

class _Feed extends RcmdController {
  final requests = <int>[];
  final pages = <int, LoadingState<List<BaseRcmdVideoItemModel>>>{};

  @override
  Future<LoadingState<List<BaseRcmdVideoItemModel>>> fetchPage(
    RcmdSource source,
    int cursor,
  ) async {
    requests.add(cursor);
    return pages[cursor] ?? const Success([]);
  }
}

void main() {
  late Directory temp;
  setUpAll(() async {
    temp = await Directory.systemTemp.createTemp('qingying_feed');
    Hive.init(temp.path);
    GStorage.setting = await Hive.openBox('setting');
  });
  tearDownAll(() async {
    await Hive.close();
    await temp.delete(recursive: true);
  });

  test('first-run filters can each be disabled', () async {
    expect(Pref.enableSponsorBlock, isTrue);
    await GStorage.setting.put(SettingBoxKey.enableSponsorBlock, false);
    expect(Pref.enableSponsorBlock, isFalse);
    expect(Pref.antiGoodsDyn, isTrue);
    expect(Pref.antiGoodsReply, isTrue);
    await GStorage.setting.put(SettingBoxKey.antiGoodsDyn, false);
    expect(Pref.antiGoodsDyn, isFalse);
    expect(Pref.antiGoodsReply, isTrue);
    await GStorage.setting.put(SettingBoxKey.antiGoodsReply, false);
    expect(Pref.antiGoodsReply, isFalse);
  });

  test(
    'empty page refills, duplicate cards merge, pagination continues',
    () async {
      final feed = _Feed()..page = 0;
      feed.pages[1] = Success([_Video('A')]);
      feed.pages[2] = Success([_Video('A'), _Video('B')]);
      await feed.queryData();
      expect(feed.requests, [0, 1, 2]);
      expect(feed.loadingState.value.data!.map((v) => v.bvid), ['A', 'B']);
      feed.pages[3] = Success(List.generate(6, (i) => _Video('next-$i')));
      await feed.onLoadMore();
      expect(feed.requests.last, 3);
      expect(feed.loadingState.value.data!.length, 8);
    },
  );

  test(
    'later failure preserves results and retries the failed cursor',
    () async {
      final feed = _Feed()..page = 0;
      feed.pages[0] = Success([_Video('A')]);
      feed.pages[1] = const Error('offline');
      await feed.queryData();
      expect(feed.loadingState.value.data!.length, 1);
      await feed.onLoadMore();
      expect(feed.requests, [0, 1, 1]);
    },
  );

  test('three empty pages stop, and first-page errors show a retry', () async {
    final feed = _Feed()..page = 0;
    await feed.queryData();
    expect(feed.requests, [0, 1, 2]);
    feed.pages[0] = const Error('offline');
    await feed.onRefresh();
    expect(feed.loadingState.value, isA<Error>());
  });
}
