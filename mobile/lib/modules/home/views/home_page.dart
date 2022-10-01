import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/modules/home/providers/home_page_render_list_provider.dart';
import 'package:immich_mobile/modules/home/providers/home_page_state.provider.dart';
import 'package:immich_mobile/modules/home/ui/asset_grid/immich_asset_grid.dart';
import 'package:immich_mobile/modules/home/ui/control_bottom_app_bar.dart';
import 'package:immich_mobile/modules/home/ui/immich_sliver_appbar.dart';
import 'package:immich_mobile/modules/home/ui/profile_drawer/profile_drawer.dart';
import 'package:immich_mobile/modules/settings/providers/app_settings.provider.dart';
import 'package:immich_mobile/modules/settings/services/app_settings.service.dart';
import 'package:immich_mobile/shared/providers/asset.provider.dart';
import 'package:immich_mobile/shared/providers/server_info.provider.dart';
import 'package:immich_mobile/shared/providers/websocket.provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettingService = ref.watch(appSettingsServiceProvider);
    var renderList = ref.watch(renderListProvider);

    final multiselectEnabled = useState(false);

    useEffect(
      () {
        ref.read(websocketProvider.notifier).connect();
        ref.read(assetProvider.notifier).getAllAsset();
        ref.watch(serverInfoProvider.notifier).getServerVersion();
        return null;
      },
      [],
    );

    void reloadAllAsset() {
      ref.read(assetProvider.notifier).getAllAsset();
    }

    Widget buildBody() {
      buildSliverAppBar() {
        return multiselectEnabled.value
            ? const SliverToBoxAdapter(
                child: SizedBox(
                  height: 70,
                  child: null,
                ),
              )
            : ImmichSliverAppBar(
                onPopBack: reloadAllAsset,
              );
      }

      void selectionListener(bool multiselect) {
        multiselectEnabled.value = multiselect;
      }

      return SafeArea(
        bottom: !multiselectEnabled.value,
        top: !multiselectEnabled.value,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                buildSliverAppBar(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 0.0),
              child: ImmichAssetGrid(
                renderList: renderList,
                assetsPerRow:
                    appSettingService.getSetting(AppSettingsEnum.tilesPerRow),
                showStorageIndicator: appSettingService
                    .getSetting(AppSettingsEnum.storageIndicator),
                listener: selectionListener,
              ),
            ),
            if (multiselectEnabled.value) ...[
              const ControlBottomAppBar(),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const ProfileDrawer(),
      body: buildBody(),
    );
  }
}
