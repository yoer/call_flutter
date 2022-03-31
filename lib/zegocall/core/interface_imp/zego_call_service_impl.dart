// Dart imports:
import 'dart:developer';

// Package imports:
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Project imports:
import './../manager/zego_service_manager.dart';
import './../model/zego_user_info.dart';
import './../zego_call_defines.dart';
import '../interface/zego_call_service.dart';

class ZegoCallServiceImpl extends IZegoCallService {
  late final FirebaseMessaging _messaging;
  late Map<String, ZegoUserInfo> _userDic;

  ZegoCallServiceImpl() : super() {
    _registerNotification();
    _addCallObserve();
    _requireNotificationsPermissions();
  }

  void updateUserDic(Map<String, ZegoUserInfo> userDic) {
    _userDic = userDic;
  }

  @override
  Future<int> callUser(String userID, String token, ZegoCallType type) async {
    ZegoUserInfo callee =
        ZegoServiceManager.shared.userService.getUserInfoByID(userID);
    if (callee.userID.isEmpty) {
      return -1;
    }
    var caller = FirebaseAuth.instance.currentUser!;

    var nowTime = DateTime.now().microsecondsSinceEpoch;
    var callID = "${caller.uid}$nowTime";
    DatabaseReference ref = FirebaseDatabase.instance.ref("call/$callID");
    var json = {
      'call_time': nowTime,
      'finish_time': 0,
      'is_video': type == ZegoCallType.kZegoCallTypeVideo,
      'users': {
        caller.uid: {
          "display_name": caller.displayName,
          "photo_url": caller.photoURL,
          "role": 0,
          "heartbeat_time": 0,
          "connected_time": 0
        },
        callee.userID: {
          "display_name": callee.userName,
          "role": 1,
          "heartbeat_time": 0,
          "connected_time": 0
        }
      }
    };
    await ref.set(json);
    return 0;
  }

  @override
  Future<int> cancelCall(String userID) async {
    return 0;
  }

  @override
  Future<int> acceptCall(String token) async {
    return 0;
  }

  @override
  Future<int> declineCall(String userID, ZegoDeclineType type) async {
    return 0;
  }

  @override
  Future<int> endCall() async {
    return 0;
  }

  void _registerNotification() async {
    // 1. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    // String? token = await FirebaseMessaging.instance.getToken();
    // log("FCM Token $token");

    // 2. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 3. Grant permission, for iOS only, Android ignore by default
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        log(message.notification?.title ?? "Empty Notification Title");
        log(message.notification?.title ?? "Empty Notification Body");
        log(message.data['title']);
        log(message.data['body']);
      });
    } else {
      log('User declined or has not accepted permission');
    }
  }

  void _addCallObserve() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('call');
    ref.onChildAdded.listen((event) {
      var selfUserID = FirebaseAuth.instance.currentUser?.uid;
      var callID = event.snapshot.key;
      var callInfo = event.snapshot.value as Map<dynamic, dynamic>;
      var users = Map<String, dynamic>.from(callInfo['users']);
      var callerID = '';
      var callerName = '';
      var callerPhotoUrl = '';
      bool isSelfBeenCall = false;
      users.forEach((key, value) {
        if (value['role'] == 0) {
          callerID = key;
          callerName = value['display_name'];
          callerPhotoUrl = value['photo_url'];
        } else if (key == selfUserID) {
          isSelfBeenCall = value['role'] == 1;
        }
      });
      if (isSelfBeenCall) {
        Map<String, String> notificationPayload = {
          'call_id': callID!,
          'caller_id': callerID,
          'caller_name': callerName,
          'caller_photo_url': callerPhotoUrl,
        };
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 1,
          // largeIcon: callerPhotoUrl,
          // icon: callerPhotoUrl,
          channelKey: 'basic_channel',
          title: '$callerName',
          body: 'Invite you to call...',
          payload: notificationPayload,
          category: NotificationCategory.Call,
        ));
      }
    });
  }

  void _requireNotificationsPermissions() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }
}
