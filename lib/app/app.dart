import 'package:audio_call_task/features/reels/bloc/reels_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/reels/bloc/reels_bloc.dart';
import '../features/reels/data/audio_player_service.dart';
import '../features/reels/ui/reels_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReelsBloc(AudioPlayerService())..add(LoadReels()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ReelsPage(),
      ),
    );
  }
}
