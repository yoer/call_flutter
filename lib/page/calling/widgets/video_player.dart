import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/service/zego_stream_service.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'avatar_background.dart';

class VideoPlayerView extends StatefulWidget {
  final String userID;
  final String userName;

  const VideoPlayerView(
      {required this.userID, required this.userName, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerViewState();
  }
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  int playingViewID = 0;
  bool isStreamReady = false;

  void onStreamReadyStateChanged(bool isReady) {
    setState(() {
      isStreamReady = isReady;
    });
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      var streamService = context.read<ZegoStreamService>();
      streamService.addStreamStateNotifier(widget.userID, onStreamReadyStateChanged);
    });
  }

  @override
  void dispose() {
    super.dispose();

    var streamService = context.read<ZegoStreamService>();
    streamService.removeStreamStateNotifier(widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: createPlayingView(context)),
        Visibility(
            visible: !isStreamReady,
            child: AvatarBackgroundView(userName: widget.userName))
      ],
    );
  }

  Widget? createPlayingView(BuildContext context) {
    return ZegoExpressEngine.instance.createPlatformView((int playingViewID) {
      playingViewID = playingViewID;

      var streamService = context.read<ZegoStreamService>();
      streamService.startPlaying(widget.userID, playingViewID);
    });
  }
}
