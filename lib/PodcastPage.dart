import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:expandable/expandable.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:connectivity/connectivity.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:daily_ad1/BackgroundAudioService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PodcastPage extends StatefulWidget {
  final podcast;
  final color;
  final darkMode;

  const PodcastPage({Key key, this.podcast, this.color, this.darkMode})
      : super(key: key);

  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> with WidgetsBindingObserver {
  List episodes = [];
  bool isLoading = false;
  String playingFileName;
  var connectivityType;
  var connectivityListener;
  bool connectivityWarningDisplayed = false;

  @override
  void initState() {
    super.initState();
    checkPlayingFile();
    connect();
    WidgetsBinding.instance.addObserver(this);
    getEpisodes();
    connectivityType = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityType = result;
      });
    });
    myBanner
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      );
  }

  @override
  void dispose() {
    super.dispose();
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    connectivityType.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
  }

  void disconnect() {
    AudioService.disconnect();
  }

  void getEpisodes() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.get(
      'https://listen-api.listennotes.com/api/v2/podcasts/${widget.podcast['listennotes_id']}?sort=recent_first',
      // Send authorization headers to the backend.
      headers: {'X-ListenAPI-Key': "af3f605216fd4033bb545e9beaf14196"},
    );
    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      print(responseJSON['episodes']);
      setState(() {
        isLoading = false;
        episodes = responseJSON['episodes'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor:
                  widget.darkMode ? Colors.grey[900] : Colors.white,
              expandedHeight: 300.0,
              floating: false,
              elevation: 3,
              forceElevated: true,
              pinned: true,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 80),
                child: Hero(
                    tag: widget.podcast['listennotes_id'],
                    child: Card(
                        elevation: 0,
                        color:
                            widget.darkMode ? Colors.grey[900] : Colors.white,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.podcast['title'],
                                            style: TextStyle(
                                                color: widget.darkMode
                                                    ? Colors.white
                                                    : widget.color,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              widget.podcast['publisher'] ?? '',
                                              style: TextStyle(
                                                  color: widget.darkMode
                                                      ? Colors.white
                                                      : Colors.black)),
                                        ],
                                      )),
                                  Container(
                                    height: 110,
                                    child: CachedNetworkImage(
                                        imageUrl:
                                            widget.podcast['thumbnail_url'],
                                        errorWidget: (context, url, error) =>
                                            new Icon(Icons.error)),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                widget.podcast['description'],
                                style: TextStyle(
                                    color: widget.darkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 15),
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ))),
              ),
            ),
          ];
        },
        body: Container(
          color: widget.darkMode ? Colors.grey[800] : Colors.white,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : StreamBuilder(
                  stream: AudioService.playbackStateStream,
                  builder: (context, snapshot) {
                    PlaybackState state = snapshot.data;
                    return ListView.builder(
                        padding: EdgeInsets.only(bottom: 100),
                        itemCount: episodes.length,
                        itemBuilder: (BuildContext context, int index) {
                          var isPlaying =
                              state?.basicState == BasicPlaybackState.playing ||
                                  AudioServiceBackground.state.basicState ==
                                      BasicPlaybackState.playing;
                          var isActive =
                              playingFileName == episodes[index]['id'];
                          var loading =
                              state?.basicState == BasicPlaybackState.buffering;
                          var duration = Duration(
                              seconds: episodes[index]['audio_length_sec']);
                          return Card(
                            elevation: 2,
                            color: widget.darkMode
                                ? Colors.grey[900]
                                : Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height: 100,
                                    child: isActive && loading
                                        ? Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                22, 31, 22, 31),
                                            child: CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        widget.darkMode
                                                            ? Colors.white
                                                            : Colors.black)))
                                        : IconButton(
                                            onPressed: () => isPlaying && isActive
                                                ? AudioService.pause()
                                                : playFromMediaId(
                                                    episodes[index]['id'],
                                                    episodes[index]['title'],
                                                    episodes[index]['audio']),
                                            iconSize: 50.0,
                                            icon: isPlaying && isActive
                                                ? Icon(Icons.pause)
                                                : Icon(Icons.play_arrow),
                                            color: widget.darkMode
                                                ? Colors.white
                                                : Colors.black)

                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.play_arrow,
                                    //     size: 60,
                                    //   ),
                                    //   onPressed: () {
                                    //     playFromMediaId(
                                    //         episodes[index]['id'],
                                    //         episodes[index]['title'],
                                    //         episodes[index]['audio']);
                                    //   },
                                    // ),
                                    ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ExpandablePanel(
                                        header: Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 5),
                                            child: Text(
                                              episodes[index]['title'] +
                                                  ' - ' +
                                                  _printDuration(duration),
                                              style: TextStyle(
                                                  color: widget.darkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            )),
                                        collapsed: Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          height: 60,
                                          child: Html(
                                            data: episodes[index]
                                                ['description'],
                                            defaultTextStyle: TextStyle(
                                                fontSize: 16,
                                                color: widget.darkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        expanded: Container(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Html(
                                              data: episodes[index]
                                                  ['description'],
                                              defaultTextStyle: TextStyle(
                                                  fontSize: 16,
                                                  color: widget.darkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                            )),
                                        tapHeaderToExpand: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }),
        ),
      ),
    );

    // return MaterialApp(
    //   title: 'Hustle Hub',
    //   home: Center(
    //     child: Container(
    //       child: DefaultTabController(
    //           length: 4,
    //           child: Scaffold(
    //             appBar: AppBar(
    //               backgroundColor: Colors.grey[900],
    //               centerTitle: true,
    //               elevation: 0,
    //               title: Text('Hustle Hub'),
    //             ),
    //             body: Container(
    //               color: Colors.white,
    //               child: Column(
    //                 children: <Widget>[
    //                   Container(
    //                     child: Hero(
    //                         tag: widget.podcast['listennotes_id'],
    //                         child: Card(
    //                             child: Row(
    //                           children: <Widget>[
    //                             Padding(
    //                                 padding: EdgeInsets.only(
    //                                     left: 20,
    //                                     top: 20,
    //                                     bottom: 20,
    //                                     right: 7),
    //                                 child: Container(
    //                                   width: MediaQuery.of(context).size.width *
    //                                       0.6,
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.start,
    //                                     children: <Widget>[
    //                                       Container(
    //                                           margin:
    //                                               EdgeInsets.only(bottom: 10),
    //                                           child: Text(
    //                                             widget.podcast['title'],
    //                                             style: TextStyle(
    //                                                 color: Colors.black,
    //                                                 fontSize: 17,
    //                                                 fontWeight:
    //                                                     FontWeight.bold),
    //                                           )),
    //                                       Container(
    //                                         child: Text(
    //                                           widget.podcast['description'],
    //                                           style: TextStyle(
    //                                               color: Colors.black,
    //                                               fontSize: 15),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 )),
    //                             Container(
    //                               height: 110,
    //                               margin: EdgeInsets.only(
    //                                   top: 5, right: 5, bottom: 5),
    //                               child: Image.network(
    //                                 widget.podcast['thumbnail_url'],
    //                               ),
    //                             )
    //                           ],
    //                         ))),
    //                   )

    //                   // Row(
    //                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   //   children: <Widget>[
    //                   //     Container(child: Text("test")),
    //                   //     Container(
    //                   //       height: 150,
    //                   //       margin:
    //                   //           EdgeInsets.only(top: 5, right: 5, bottom: 5),
    //                   //       child: Hero(
    //                   //           tag: widget.podcast['listennotes_id'],
    //                   //           child: Image.network(
    //                   //             widget.podcast['thumbnail_url'],
    //                   //           )),
    //                   //     ),
    //                   //   ],
    //                   // )
    //                 ],
    //               ),
    //             ),
    //           )),
    //     ),
    //   ),
    // );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void checkPlayingFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var savedPlayingFileName = prefs.getString('playingFileName');
    // var savedPlayingFileNameDuration = prefs.getInt('playingFileNameDuration');

    if (savedPlayingFileName != null) {
      if (this.mounted)
        setState(() {
          playingFileName = savedPlayingFileName;
        });
    }
    // if (savedPlayingFileNameDuration != null) {
    //   if (this.mounted)
    //     setState(() {
    //       _duration = savedPlayingFileNameDuration;
    //     });
    // }
  }

  void playFromMediaId(fileName, title, audioUrl) {
    if (connectivityType == ConnectivityResult.mobile &&
        !connectivityWarningDisplayed) {
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Connection Warning",
        desc: "It's recommended to turn on WiFi when streaming",
        buttons: [
          DialogButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                connectivityWarningDisplayed = true;
              });
            },
            color: Colors.red,
          ),
          DialogButton(
            child: Text(
              "Proceed",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              playMedia(fileName, title, audioUrl);
              setState(() {
                connectivityWarningDisplayed = true;
              });
            },
            // color: widget.color,
          )
        ],
      ).show();
    } else {
      playMedia(fileName, title, audioUrl);
    }
  }

  void playMedia(fileName, title, audioUrl) async {
    print(fileName);
    print(audioUrl);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fileInfoJson = "{\"fileName\":\"" +
        fileName +
        "\",\"title\":\"" +
        title +
        "\",\"audioUrl\":\"" +
        audioUrl +
        "\",\"type\":\"podcast\"}";
    if (AudioService.playbackState == null ||
        AudioService.playbackState?.basicState == BasicPlaybackState.none ||
        AudioService.playbackState?.basicState == BasicPlaybackState.stopped) {
      AudioService.start(
        backgroundTask: backgroundTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Hustle Hub Player',
        androidNotificationIcon: 'mipmap/ic_launcher',
      ).then((response) {
        if (response) {
          AudioService.playFromMediaId(fileInfoJson);
        }
      });
    } else {
      if (AudioService.playbackState?.basicState == BasicPlaybackState.paused &&
          fileName == playingFileName) {
        AudioService.play();
      } else {
        AudioService.playFromMediaId(fileInfoJson);
      }
    }
    await prefs.setString('playingFileName', fileName);
    setState(() {
      playingFileName = fileName;
    });
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  testDevices: <String>["E69FA5F1C4163C34800437316A07E39B"],
);

BannerAd myBanner = BannerAd(
  adUnitId: 'ca-app-pub-3596613421523831/8139553828',
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
);
