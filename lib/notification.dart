import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mbm_store/pages/approval/leave.dart';
import 'package:mbm_store/pages/approval/order_costing.dart';
import 'package:mbm_store/pages/approval/pi_payment.dart';
import 'package:mbm_store/pages/contact.dart';

import 'pages/BillDetails.dart';

class NotificationSetup {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeNotification() async {
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'high_importance_channel',
        channelName: 'Chat Notifications',
        importance: NotificationImportance.Max,
        vibrationPattern: highVibrationPattern,
        channelShowBadge: true,
        channelDescription: 'Chat Notifications',
      ),
    ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void configurePushNotifications(BuildContext context) async {
    initializeNotification();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // if(Platform.isIOS) getIOSPermission();

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null && message.notification!.body != null) {
        if (kDebugMode) {
          print("Received Notification: ${message.notification!.body}");
          print("Received Data: ${message.data}");
        }
        Map<String, dynamic>? payload = message.data;
        createOrderNotifications(
          title: message.notification!.title,
          body: message.notification!.body,
          payload: payload?.cast<String, String>(),
        );
      }
    });
  }


  Future<void> createOrderNotifications({String? title, String? body, payload}) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          payload: payload,
          icon: null,

        ));
        // Get.to(
        //   BillDetails(
        //     billId: body,
        //   ),
        // );
  }

  void eventListenerCallback(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  void getIOSPermission() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }
}

@pragma("vm:entry-point")
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
      // Code after click notification goes here
      final reqData = receivedNotification;
      print('Clicked');
      print('ID = ${reqData.payload!['id']}');
      print('Type = ${reqData.payload!['type']}');
      // if(reqData.payload!['type'] == 'order_costing'){
      //   Get.to(() => ApprovalDetailsPageOrderCosting(
      //     approvalId: reqData.payload!['id'],
      //   ));
      // }else if(reqData.payload!['type'] == 'pi_tt_payment'){
      //   Get.to(() => ApprovalDetailsPagePI(
      //     approvalId: reqData.payload!['id'],
      //   ));
      // }else if(reqData.payload!['type'] == 'employee_leave'){
      //   Get.to(() => ApprovalDetailsLeave(
      //     approvalId: reqData.payload!['id'],
      //   ));
      // }
      // Get.to(() => ContactPage(
      //   reqData: reqData,
      // ));
  }
}