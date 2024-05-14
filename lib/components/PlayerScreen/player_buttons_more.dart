import 'package:Finamp/components/AlbumScreen/song_menu.dart';
import 'package:Finamp/components/PlayerScreen/queue_source_helper.dart';
import 'package:Finamp/models/jellyfin_models.dart';
import 'package:Finamp/services/music_player_background_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get_it/get_it.dart';

import '../../models/finamp_models.dart';

enum PlayerButtonsMoreItems { shuffle, repeat, addToPlaylist, sleepTimer }

class PlayerButtonsMore extends ConsumerWidget {
  final audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();
  final BaseItemDto? item;
  final FinampQueueItem? queueItem;

  PlayerButtonsMore({super.key, required this.item, required this.queueItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconTheme(
      data: IconThemeData(
        color: IconTheme.of(context).color,
        size: 24,
      ),
      child: IconButton(
        icon: const Icon(
          TablerIcons.menu_2,
        ),
        visualDensity: VisualDensity.compact,
        onPressed: () async {
          if (item == null) return;
          var inPlaylist = queueItemInPlaylist(queueItem);
          await showModalSongMenu(
            context: context,
            item: item!,
            usePlayerTheme: true,
            showPlaybackControls: true, // show controls on player screen
            parentItem: inPlaylist ? queueItem!.source.item : null,
            isInPlaylist: inPlaylist,
          );
        },
      ),
    );
  }
}
