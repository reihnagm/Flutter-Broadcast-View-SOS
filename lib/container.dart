import 'package:broadcast_view_sos/providers/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:broadcast_view_sos/providers/network.dart';
import 'package:broadcast_view_sos/providers/videos.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerFactory(() => NetworkProvider());
  getIt.registerFactory(() => VideoProvider());
  getIt.registerFactory(() => FirebaseProvider());
}