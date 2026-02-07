import 'package:audio_call_task/core/utils/logger.dart';
import 'package:audio_call_task/features/call/bloc/call_bloc.dart';
import 'package:audio_call_task/features/call/bloc/call_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: // reels_page.dart
         FloatingActionButton(
  onPressed: () {
    const channelId = 'test_agora_channel';
    Logger.info('🔴 FAB pressed - channelId: $channelId');

    context.read<CallBloc>().add(
      IncomingCall("John Doe", channelId),
    );
  },
  child: const Icon(Icons.call),
),

      body: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final loaded = state as ReelsLoaded;

          return GestureDetector(
            onTap: () {
              context.read<ReelsBloc>().add(TogglePlayPause());
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: loaded.reels.length,
                  onPageChanged: (index) {
                    context.read<ReelsBloc>().add(
                          ReelChanged(index, loaded.reels[index]),
                        );
                  },
                  itemBuilder: (_, index) {
                    return Center(
                      child: Text(
                        loaded.reels[index].title,
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  },
                ),
                if (loaded.showOverlayIcon)
                  Icon(
                    loaded.isPlaying ? Icons.play_arrow : Icons.pause,
                    size: 80,
                    color: Colors.black.withOpacity(0.85),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
