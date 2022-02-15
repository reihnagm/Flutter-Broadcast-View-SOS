import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:video_player/video_player.dart';

import 'package:broadcast_view_sos/services/sqlite.dart';

enum ListenVStatus { idle, loading, loaded, empty, error }

class VideoProvider with ChangeNotifier {

  @override
  void dispose() {
    for (var vi in v) {
      VideoPlayerController vpc = vi["video"];
      vpc.dispose(); 
    }
    super.dispose();
  }
  
  String _loc = "Location";
  String get loc => _loc;

  List _v = [];
  List get v => [..._v]; 

  ListenVStatus _listenVStatus = ListenVStatus.idle;
  ListenVStatus get listenVStatus => _listenVStatus; 

  void setStateListenVStatus(ListenVStatus listenVStatus) {
    _listenVStatus = listenVStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> listenV(BuildContext context, [dynamic data]) async {
    setStateListenVStatus(ListenVStatus.loading);
    if(data != null) {
      await DBHelper.insert("sos", {
        "id": data["id"],
        "mediaUrl": data["mediaUrl"],
        "lat": data["lat"],
        "lng": data["lng"],
        "msg": data["msg"]
      });
      List<Map<String, dynamic>> listSos = await DBHelper.fetchSos(context);
      _v = [];
      for (var sos in listSos) {
        List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(sos["lat"]), double.parse(sos["lng"]));
        Placemark place = placemarks[0];
        _loc = "${place.thoroughfare} ${place.subThoroughfare}\n${place.locality}, ${place.postalCode}";
        _v.add({
          "id": sos["id"],
          "video": VideoPlayerController.network(sos["mediaUrl"])
          ..addListener(() => notifyListeners())
          ..setLooping(false)
          ..initialize(),
          "lat": sos["lat"],
          "lng": sos["lng"],
          "loc": loc,
          "msg": sos["msg"],
        });
      }
    } else {
      List<Map<String, dynamic>> listSos = await DBHelper.fetchSos(context);
      List<Map<String, dynamic>> sosAssign = [];
      _v = [];
      for (var sos in listSos) {
        List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(sos["lat"]), double.parse(sos["lng"]));
        Placemark place = placemarks[0];
        _loc = "${place.thoroughfare} ${place.subThoroughfare}\n${place.locality}, ${place.postalCode}";
        sosAssign.add({
          "id": sos["id"],
          "video": VideoPlayerController.network(sos["mediaUrl"])
          ..addListener(() => notifyListeners())
          ..setLooping(false)
          ..initialize(),
          "lat": sos["lat"],
          "lng": sos["lng"],
          "loc": loc,
          "msg": sos["msg"],
        });
      }
      _v = sosAssign;
    }
    setStateListenVStatus(ListenVStatus.loaded);
    if(v.isEmpty) {
      setStateListenVStatus(ListenVStatus.empty);
    }
  }

  Future<void> deleteV(BuildContext context, {required String id}) async {
    try {
      await DBHelper.delete("sos", id);
      _v.removeWhere((el) => el["id"] == id);
      Future.delayed(Duration.zero, () => notifyListeners());
    } catch(e) {
      debugPrint(e.toString());
    }
  }

}