// Project imports:
import 'package:zego_call_flutter/zegocall/command/zego_command.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';

class ZegoLoginCommand extends ZegoCommand {
  ZegoLoginCommand(String path, Map<String, dynamic> parameters)
      : super(apiLogin, parameters) {
    parameters["id"] = "";
    parameters["token"] = "";
  }
}
