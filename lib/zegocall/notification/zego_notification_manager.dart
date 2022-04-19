// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

// Project imports:
import '../../logger.dart';
import './../core/manager/zego_service_manager.dart';
import './../core/model/zego_user_info.dart';
import './../core/zego_call_defines.dart';
import 'zego_notification_call_model.dart';

const firebaseChannelGroupName = 'firebase_channel_group';
const firebaseChannelKey = 'firebase_channel';
const String callRingName = 'CallRing.wav';

class ZegoNotificationManager {
  static var shared = ZegoNotificationManager();

  bool isRingTimerRunning = false;
  AudioPlayer? audioPlayer;
  late AudioCache audioCache;

  void init() {
    AwesomeNotifications()
        .initialize(
            // set the icon to null if you want to use the default app icon
            '',
            [
              NotificationChannel(
                  channelGroupKey: firebaseChannelGroupName,
                  channelKey: firebaseChannelKey,
                  channelName: 'Firebase notifications',
                  channelDescription: 'Notification channel for firebase',
                  defaultColor: const Color(0xFF9D50DD),
                  playSound: true,
                  enableVibration: true,
                  vibrationPattern: lowVibrationPattern,
                  onlyAlertOnce: false,
                  ledColor: Colors.white)
            ],
            // Channel groups are only visual and are not required
            channelGroups: [
              NotificationChannelGroup(
                  channelGroupkey: firebaseChannelGroupName,
                  channelGroupName: 'Firebase group')
            ],
            debug: true)
        .then(onInitFinished);

    audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  void uninit() async {
    stopRing();

    await audioCache.clearAll();
  }

  void onInitFinished(bool initResult) async {
    requestFirebaseMessagePermission();
    requestAwesomeNotificationsPermission();

    FirebaseMessaging.onBackgroundMessage(onFirebaseBackgroundMessage);

    listenAwesomeNotification();
  }

  void startRing() async {
    if (isRingTimerRunning) {
      logInfo('ring is running');
      return;
    }

    logInfo('start ring');

    isRingTimerRunning = true;

    await audioCache.loop(callRingName).then((player) => audioPlayer = player);
    Vibrate.vibrate();

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      logInfo('ring timer periodic');
      if (!isRingTimerRunning) {
        logInfo('ring timer ended');

        audioPlayer?.stop();

        timer.cancel();
      } else {
        Vibrate.vibrate();
      }
    });
  }

  void stopRing() async {
    logInfo('stop ring');

    isRingTimerRunning = false;

    audioPlayer?.stop();
  }

  void requestFirebaseMessagePermission() async {
    // 1. Instantiate Firebase Messaging
    String? token = await FirebaseMessaging.instance.getToken();
    logInfo("FCM Token $token");

    // 2. On iOS, this helps to take the user permissions
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 3. Grant permission, for iOS only, Android ignore by default
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logInfo('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen(onFirebaseForegroundMessage);
    } else {
      logInfo('User declined or has not accepted permission');
    }
  }

  void requestAwesomeNotificationsPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        logInfo('requestPermissionToSendNotifications');

        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((bool hasPermission) {
          logInfo('User granted permission: $hasPermission');
        });
      }
    });
  }

  void listenAwesomeNotification() {
    AwesomeNotifications().actionStream.listen((receivedAction) {
      if (receivedAction.channelKey != firebaseChannelKey) {
        logInfo('unknown channel key');
        return;
      }

      var model = ZegoNotificationModel.fromMap(
          receivedAction.payload ?? <String, String>{});
      logInfo('receive:${model.toMap()}');

      //  dispatch notification message
      var caller = ZegoUserInfo(model.callerID, model.callerName);
      var callType =
          ZegoCallTypeExtension.mapValue[int.parse(model.callTypeID)] ??
              ZegoCallType.kZegoCallTypeVoice;
      ZegoServiceManager.shared.callService.delegate
          ?.onReceiveCallInvite(caller, callType);
    });
  }

  Future<void> onFirebaseForegroundMessage(RemoteMessage message) async {
    // for more reliable, faster notification in foreground
    // use listener in firebase manager
    return;

    // logInfo("[firebase] foreground message: $message");
    // onFirebaseRemoteMessageReceive(message);
  }

  Future<void> onFirebaseRemoteMessageReceive(RemoteMessage message) async {
    if (isRingTimerRunning) {
      return;
    }

    startRing();

    logInfo('remote message receive: ${message.data}');
    var notificationModel = ZegoNotificationModel.fromMessageMap(message.data);

    Map<String, dynamic> notificationAdapter = {
      NOTIFICATION_CONTENT: {
        NOTIFICATION_ID: Random().nextInt(2147483647),
        NOTIFICATION_GROUP_KEY: firebaseChannelGroupName,
        NOTIFICATION_CHANNEL_KEY: firebaseChannelKey,
        NOTIFICATION_TITLE: ZegoCallTypeExtension
                .mapValue[int.parse(notificationModel.callTypeID)]?.string ??
            "",
        NOTIFICATION_BODY: "${notificationModel.callerName} Calling...",
        NOTIFICATION_PAYLOAD: notificationModel.toMap(),
        NOTIFICATION_PLAY_SOUND: false,
        NOTIFICATION_ENABLE_VIBRATION: false,
      }
    };
    logInfo('create notification: $notificationAdapter');
    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  }
}

Future<void> onFirebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  logInfo("message: $message");
  ZegoNotificationManager.shared.onFirebaseRemoteMessageReceive(message);
}
