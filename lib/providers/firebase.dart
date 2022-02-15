import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

import 'package:broadcast_view_sos/utils/constant.dart';

class FirebaseProvider with ChangeNotifier {
  Future<void> sendNotification({
    required String body,
  }) async {
    Map<String, dynamic> data = {};
    data = {
      "to": await FirebaseMessaging.instance.getToken(),
      "collapse_key" : "Broadcast SOS",
      "priority":"high",
      "notification": {
        "title": "SOS",
        "body": body,
        "sound":"default",
      },
      "android": {
        "notification": {
          "channel_id": "sos",
        }
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      },
    };
    try { 
      Dio dio = Dio();
      await dio.post("https://fcm.googleapis.com/fcm/send", 
        data: data,
        options: Options(
          headers: {
            "Authorization": "key=${AppConstants.firebaseKey}"
          }
        )
      );
    } on DioError catch(e) {
      debugPrint(e.response!.data.toString());
      debugPrint(e.response!.statusMessage.toString());
      debugPrint(e.response!.statusCode.toString());
    }
  }
}