// Project imports:
import './../../zegocall/core/model/zego_user_info.dart';
import './../../zegocall/core/zego_call_defines.dart';

mixin ZegoCallManagerDelegate {
  /// Callback for receive an incoming call
  ///
  /// Description: This callback will be triggered when receiving an incoming call.
  ///
  /// - Parameter caller: refers to the caller information.
  /// - Parameter type: indicates the call type.  ZegoCallTypeVoice: Voice call.  ZegoCallTypeVideo: Video call.
  onReceiveCallInvite(ZegoUserInfo caller, ZegoCallType type);

  /// Callback for receive a canceled call
  ///
  /// Description: This callback will be triggered when the caller cancel the outbound call.
  ///
  /// - Parameter caller: refers to the caller information.
  onReceiveCallCanceled(ZegoUserInfo caller);

  /// Callback for timeout a call
  ///
  /// - Description: This callback will be triggered when the caller or called user ends the call.
  onReceiveCallTimeout(ZegoCallTimeoutType type, ZegoUserInfo caller);

  /// Callback for end a call
  ///
  /// - Description: This callback will be triggered when the caller or called user ends the call.
  onReceivedCallEnded();

  /// Callback for call is accept
  ///
  /// - Description: This callback will be triggered when called accept the call.
  onReceiveCallAccepted(ZegoUserInfo callee);

  /// Callback for call is decline
  ///
  /// - Description: This callback will be triggered when called refused the call.
  onReceiveCallDeclined(ZegoUserInfo userInfo, ZegoDeclineType type);
}
