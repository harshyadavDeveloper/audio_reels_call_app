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
      body: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final loaded = state as ReelsLoaded;

          return PageView.builder(
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
          );
        },
      ),
    );
  }
}
