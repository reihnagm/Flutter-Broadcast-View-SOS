import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:broadcast_view_sos/providers.dart';
import 'package:broadcast_view_sos/providers/network.dart';
import 'package:broadcast_view_sos/providers/videos.dart';
import 'package:broadcast_view_sos/services/socket.dart';
import 'package:broadcast_view_sos/container.dart' as core;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await core.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'SOS Broadcast View',
        debugShowCheckedModeBanner: false,
        home: MyHomePage(key: UniqueKey()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  dynamic currentBackPressTime;

  @override 
  void initState() {
    super.initState();
    if(mounted) {
      context.read<VideoProvider>().listenV(context);
    }
    if(mounted) {
      context.read<NetworkProvider>().checkConnection(context);
    }
    if(mounted) {
      SocketServices.shared.connect(context);
    }
  }

  @override 
  void dispose() {
    SocketServices.shared.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tekan sekali lagi untuk keluar");
          return Future.value(false);
        }
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: const Text("SOS Broadcast View",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Consumer<NetworkProvider>(
                builder: (BuildContext context, NetworkProvider networkProvider, Widget? child) {
                  if(networkProvider.connectionStatus == ConnectionStatus.offInternet) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        size: 20.0,
                        color: Colors.black87,
                      ),
                    );
                  }
                  return Consumer<VideoProvider>(
                    builder: (BuildContext context, VideoProvider videoProvider, Widget? child) {
                      return RefreshIndicator(
                        backgroundColor: Colors.black,
                        color: Colors.white,
                        onRefresh: () {
                          return Future.sync(() {
                            videoProvider.listenV(context);
                            SocketServices.shared.connect(context);
                          });
                        },
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          slivers: [

                            if(videoProvider.listenVStatus == ListenVStatus.loading)
                              const SliverFillRemaining(
                                child: Center(
                                  child: SpinKitThreeBounce(
                                    size: 20.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              if(videoProvider.v.isEmpty) 
                                const SliverFillRemaining(
                                  child: Center(
                                    child: Text("There is no Videos",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                                

                            SliverPadding(
                              padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                            
                                        Container(
                                          margin: const EdgeInsets.all(16.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            itemCount: videoProvider.v.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              
                                              VideoPlayerController? vid = videoProvider.v[i]["video"];

                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 5.0),
                                                child: Card(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Column( 
                                                      children: [
                        
                                                        vid != null && vid.value.isInitialized
                                                        ? Container(
                                                            alignment: Alignment.topCenter, 
                                                            child: Stack(
                                                              children: [
                                                                AspectRatio(
                                                                  aspectRatio: vid.value.aspectRatio,
                                                                  child: VideoPlayer(vid),
                                                                ),
                                                                Positioned.fill(
                                                                  child: GestureDetector(
                                                                    behavior: HitTestBehavior.opaque,
                                                                    onTap: () => vid.value.isPlaying 
                                                                    ? vid.pause() 
                                                                    : vid.play(),
                                                                    child: Stack(
                                                                      children: [
                                                                        vid.value.isPlaying 
                                                                        ? Container() 
                                                                        : Container(
                                                                            alignment: Alignment.center,
                                                                            child: const Icon(
                                                                              Icons.play_arrow,
                                                                              color: Colors.white,
                                                                              size: 80
                                                                            ),
                                                                          ),
                                                                        Positioned(
                                                                          bottom: 0.0,
                                                                          left: 0.0,
                                                                          right: 0.0,
                                                                          child: VideoProgressIndicator(
                                                                            vid,
                                                                            allowScrubbing: true,
                                                                          )
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                )
                                                              ],
                                                            )
                                                          )
                                                        : const SizedBox(
                                                          height: 200,
                                                          child: SpinKitThreeBounce(
                                                            size: 20.0,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                        
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(videoProvider.v[i]["msg"].toString(),
                                                                          style: const TextStyle(
                                                                            fontSize: 16.0,
                                                                            fontWeight: FontWeight.bold
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 20.0),
                                                                        Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 4,
                                                                                  child: Text("Lat", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 4,
                                                                                  child: Text(":", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 33,
                                                                                  child: Text("${videoProvider.v[i]['lat']}",
                                                                                    style: const TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  )
                                                                                )
                                                                              ],
                                                                            ),
                                                                            const SizedBox(height: 8.0),
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 4,
                                                                                  child: Text("Lng", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 4,
                                                                                  child: Text(":", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 33,
                                                                                  child: Text("${videoProvider.v[i]['lng']}",
                                                                                    style: const TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  )
                                                                                )
                                                                              ],
                                                                            ),
                                                                            const SizedBox(height: 12.0),
                                                                            Row(
                                                                              children: [
                                                                                const Expanded(
                                                                                  flex: 6,
                                                                                  child: Text("Lokasi", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const Expanded(
                                                                                  flex: 4,
                                                                                  child: Text(":", 
                                                                                    style: TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 28,
                                                                                  child: Text("${videoProvider.v[i]['loc']}",
                                                                                    style: const TextStyle(
                                                                                      fontSize: 13.0
                                                                                    ),
                                                                                  )
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ) 
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      children: [
                                                                        // Material(
                                                                        //   color: Colors.transparent,
                                                                        //   child: InkWell(
                                                                        //     onTap: () {
                                                                        //       videoProvider.deleteV(
                                                                        //         context, 
                                                                        //         id: videoProvider.v[i]["id"].toString()
                                                                        //       );
                                                                        //     },
                                                                        //     child: const Padding(
                                                                        //       padding: EdgeInsets.all(8.0),
                                                                        //       child: Icon(
                                                                        //         Icons.remove_circle,
                                                                        //         color: Colors.redAccent,
                                                                        //         size: 30.0,
                                                                        //       ),
                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                        Material(
                                                                          color: Colors.transparent,
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              await launch("https://www.google.com/maps?daddr=${videoProvider.v[i]["lat"]},${videoProvider.v[i]["lng"]}");
                                                                            },
                                                                            child: const Padding(
                                                                              padding: EdgeInsets.all(8.0),
                                                                              child: Text("Lihat di Maps",
                                                                                style: TextStyle(
                                                                                  color: Colors.blueAccent,
                                                                                  fontSize: 14.0,
                                                                                  decoration: TextDecoration.underline,
                                                                                  fontStyle: FontStyle.italic
                                                                                ),
                                                                              )
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        )
                        
                                                      ],  
                                                    )
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        ),
                                        
                                        
                                      ],
                                    ),
                                  ),
                                ])
                              ),
                            )
                          ],
                        )

                            
                      );

                    },
                  );

                },   
              );
            },
          ),
        )
        
      ),
    );
  }
}

