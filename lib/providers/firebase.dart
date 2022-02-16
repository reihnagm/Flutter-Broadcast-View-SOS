import 'dart:convert';

import 'package:broadcast_view_sos/main.dart';
import 'package:broadcast_view_sos/services/notification.dart';
import 'package:broadcast_view_sos/utils/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:broadcast_view_sos/data/repository/firebase.dart';

class FirebaseProvider with ChangeNotifier {
  final FirebaseRepo firebaseRepo;
  final SharedPreferences sharedPreferences;

  FirebaseProvider({
    required this.firebaseRepo,
    required this.sharedPreferences
  });

  Future<void> setupInteractedMessage(BuildContext context) async {
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Map<String, dynamic> data = message.data;
      // Map<String, dynamic> payload = json.decode(data["payload"]);
      GlobalVariable.navState.currentState!.pushAndRemoveUntil(
        PageRouteBuilder(pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return MyApp(key: UniqueKey());
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        }), (Route<dynamic> route) => route.isFirst
      );
    });
  }

  void listenNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // RemoteNotification notification = message.notification!;
      Map<String, dynamic> data = message.data;
      Map<String, dynamic> payload = json.decode(data["payload"]);
      NotificationService.showNotification(
        title: payload["title"],
        body: payload["body"],
        payload: payload,
      );
    });
  }

  Future<void> initFcm(BuildContext context) async {
    try {
      await firebaseRepo.initFcm(
        context, 
        lat: getCurrentLat, 
        lng: getCurrentLng
      );
    } catch(e) {
      debugPrint(e.toString());
    } 
  }

  double get getCurrentLat => sharedPreferences.getDouble("lat") ?? 0.0;  
  double get getCurrentLng => sharedPreferences.getDouble("long") ?? 0.0;  
}