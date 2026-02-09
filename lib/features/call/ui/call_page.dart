import 'package:audio_call_task/core/utils/logger.dart';
import 'package:audio_call_task/features/call/bloc/call_bloc.dart';
import 'package:audio_call_task/features/call/bloc/call_event.dart';
import 'package:audio_call_task/features/call/bloc/call_state.dart';
import 'package:audio_call_task/features/call/data/call_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.info('🎨 CallPage: Building...');
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        Logger.info('🎨 CallPage: Current state = $state');

        if (state is! CallInProgress) {
          Logger.info(
              '🎨 CallPage: State is not CallInProgress, returning SizedBox.shrink()');
          return const SizedBox.shrink();
        }

        final call = state.call;
        Logger.info('🎨 CallPage: Call status = ${call.status}');

        if (call.status == CallStatus.incoming) {
          Logger.info('🎨 CallPage: Showing incoming call UI');
          return _IncomingCallUI(call.callerName);
        }

        if (call.status == CallStatus.accepted) {
          Logger.info('🎨 CallPage: Showing call connected UI');
          return _ActiveCallUI();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _IncomingCallUI extends StatelessWidget {
  final String callerName;

  const _IncomingCallUI(this.callerName);

  @override
  Widget build(BuildContext context) {
    Logger.info('🎨 _IncomingCallUI: Building for caller: $callerName');
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              callerName,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Incoming call...',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    Logger.error('❌ Decline button pressed');
                    context.read<CallBloc>().add(DeclineCall());
                  },
                  icon: const Icon(Icons.call_end),
                  iconSize: 50,
                  color: Colors.red,
                ),
                IconButton(
                  onPressed: () {
                    Logger.success('✅ Accept button pressed');
                    context.read<CallBloc>().add(AcceptCall());
                  },
                  icon: const Icon(Icons.call),
                  iconSize: 50,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCallUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Call Connected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 40),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                context.read<CallBloc>().add(EndCall());
              },
              child: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }
}
