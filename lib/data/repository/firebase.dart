import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:broadcast_view_sos/utils/constant.dart';
import 'package:broadcast_view_sos/utils/exceptions.dart';

class FirebaseRepo {
  final SharedPreferences sharedPreferences;
  FirebaseRepo({
    required this.sharedPreferences
  });
  
  Future<void> initFcm(BuildContext context, {
    required double lat, 
    required double lng
  }) async {
    try {
      Dio dio = Dio();
      Response res = await dio.post("${AppConstants.baseUrl}/init-fcm", data: 
        {
          "fcm_secret": await FirebaseMessaging.instance.getToken(),
          "lat": lat.toString(),
          "lng": lng.toString()
        }
      );
      debugPrint("Initialize FCM : ${res.statusCode}");
    } on DioError catch(e) {
      if(e.response!.statusCode == 400 || e.response!.statusCode == 401 || e.response!.statusCode == 404 || e.response!.statusCode == 500 || e.response!.statusCode == 502) {
        throw CustomException("(${e.response!.statusCode}) Create FCM");
      }
    } catch(e) {
      debugPrint(e.toString());
    }
  }

}