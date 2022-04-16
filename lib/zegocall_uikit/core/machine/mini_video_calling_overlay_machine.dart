// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

enum MiniVideoCallingOverlayState {
  kIdle,
  kWaiting,
  kRemoteUserWithVideo,
  kLocalUserWithVideo,
  kBothWithoutVideo,
}

typedef MiniVideoCallingOverlayMachineStateChanged = void Function(
    MiniVideoCallingOverlayState);

class MiniVideoCallingOverlayMachine {
  final machine = sm.Machine<MiniVideoCallingOverlayState>();
  MiniVideoCallingOverlayMachineStateChanged? onStateChanged;

  late sm.State<MiniVideoCallingOverlayState> stateIdle;
  late sm.State<MiniVideoCallingOverlayState> stateRemoteUserWithVideo;
  late sm.State<MiniVideoCallingOverlayState> stateLocalUserWithVideo;
  late sm.State<MiniVideoCallingOverlayState> stateBothWithoutVideo;

  void init() {
    machine.onAfterTransition.listen((event) {
      log('[state machine] mini video, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    // Config state
    stateIdle = machine.newState(MiniVideoCallingOverlayState.kIdle);
    stateRemoteUserWithVideo =
        machine.newState(MiniVideoCallingOverlayState.kRemoteUserWithVideo);
    stateLocalUserWithVideo =
        machine.newState(MiniVideoCallingOverlayState.kLocalUserWithVideo);
    stateBothWithoutVideo = machine.newState(MiniVideoCallingOverlayState
        .kBothWithoutVideo); //  todo page handle 监听处理
  }

  MiniVideoCallingOverlayState getPageState() {
    return machine.current?.identifier ?? MiniVideoCallingOverlayState.kIdle;
  }
}
