import 'dart:async';

import 'package:audio_call_task/core/network/api_client.dart';
import 'package:audio_call_task/core/notifications/call_action_stream.dart';
import 'package:audio_call_task/features/call/bloc/call_bloc.dart';
import 'package:audio_call_task/features/call/bloc/call_event.dart';
import 'package:audio_call_task/features/call/bloc/call_state.dart';
import 'package:audio_call_task/features/call/data/agora_service.dart';
import 'package:audio_call_task/features/call/ui/call_page.dart';
import 'package:audio_call_task/features/reels/bloc/reels_bloc.dart';
import 'package:audio_call_task/features/reels/bloc/reels_event.dart';
import 'package:audio_call_task/features/reels/data/audio_player_service.dart';
import 'package:audio_call_task/features/reels/data/reels_api_service.dart';
import 'package:audio_call_task/features/reels/ui/reels_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final CallBloc _callBloc;
  late final ReelsBloc _reelsBloc;

  late final StreamSubscription _callActionSub;
  late final StreamSubscription _callStateSub;
  final apiClient = ApiClient();


  @override
  void initState() {
    super.initState();

    _reelsBloc = ReelsBloc(AudioPlayerService(), ReelsApiService(apiClient))..add(LoadReels());
    _callBloc = CallBloc(AgoraService());

    _callActionSub = CallActionStream.stream.listen((action) {
      if (action == CallNotificationAction.accept) {
        _callBloc.add(AcceptCall());
      } else if (action == CallNotificationAction.decline) {
        _callBloc.add(DeclineCall());
      }
    });

    _callStateSub = _callBloc.stream.listen((callState) {
      if (callState is CallInProgress) {
        _reelsBloc.add(PauseForCall());
      }

      if (callState is CallIdle) {
        _reelsBloc.add(ResumeAfterCall());
      }
    });
  }

  @override
  void dispose() {
    _callActionSub.cancel();
    _callStateSub.cancel();
    _callBloc.close();
    _reelsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _reelsBloc),
        BlocProvider.value(value: _callBloc),
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
