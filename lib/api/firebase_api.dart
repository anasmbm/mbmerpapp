import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage? message) async {
    if (message != null) {
      print('Title: ${message.notification?.title ?? "No title"}');
      print('Body: ${message.notification?.body ?? "No body"}');
      print('Payload: ${message.data}');
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}