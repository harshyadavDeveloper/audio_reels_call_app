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
      backgroundColor: Colors.black,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          const channelId = 'test_agora_channel';
          Logger.info('🔴 FAB pressed - channelId: $channelId');

          context.read<CallBloc>().add(
                IncomingCall("John Doe", channelId),
              );
        },
        child: const Icon(Icons.call, color: Colors.black),
      ),

      body: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final loaded = state as ReelsLoaded;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.read<ReelsBloc>().add(TogglePlayPause());
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// 🔹 REELS CONTENT
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    );
                  },
                ),

                /// 🔹 PLAY / PAUSE OVERLAY (YouTube Shorts style)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0)
                          .animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: loaded.showOverlayIcon
                      ? Container(
                          key: ValueKey(loaded.isPlaying),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            loaded.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 72,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
