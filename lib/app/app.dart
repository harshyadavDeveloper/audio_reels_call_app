import 'package:audio_call_task/features/call/bloc/call_bloc.dart';
import 'package:audio_call_task/features/reels/bloc/reels_event.dart';
import 'package:audio_call_task/features/ui/call_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/reels/bloc/reels_bloc.dart';
import '../features/reels/data/audio_player_service.dart';
import '../features/reels/ui/reels_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReelsBloc(AudioPlayerService())..add(LoadReels()),
        ),
        BlocProvider(
          create: (_) => CallBloc(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Stack(
          children: [
            ReelsPage(),
            CallPage(), 
          ],
        ),
      ),
    );
  }
}