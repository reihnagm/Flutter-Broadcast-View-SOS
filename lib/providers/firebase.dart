import 'dart:convert';

import 'package:broadcast_view_sos/services/notification.dart';
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