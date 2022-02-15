import 'package:broadcast_view_sos/data/repository/firebase.dart';
import 'package:broadcast_view_sos/providers/firebase.dart';
import 'package:broadcast_view_sos/providers/location.dart';
import 'package:broadcast_view_sos/services/notification.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:broadcast_view_sos/providers/network.dart';
import 'package:broadcast_view_sos/providers/videos.dart';

final getIt = GetIt.instance;

Future<void> init() async {

  getIt.registerLazySingleton(() => NotificationService(sharedPreferences: getIt()));
  getIt.registerLazySingleton(() => FirebaseRepo(sharedPreferences: getIt()));

  getIt.registerFactory(() => NetworkProvider(sharedPreferences: getIt()));
  getIt.registerFactory(() => VideoProvider(sharedPreferences: getIt()));
  getIt.registerFactory(() => LocationProvider(sharedPreferences: getIt()));
  getIt.registerFactory(() => FirebaseProvider(firebaseRepo: getIt(), sharedPreferences: getIt()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
}