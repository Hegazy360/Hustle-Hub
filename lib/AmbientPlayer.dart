import 'dart:async';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:daily_ad1/AmbientMusicCard.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_ad1/BackgroundAudioService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbientPlayer extends StatefulWidget {
  final color;
  final darkMode;

  const AmbientPlayer({Key key, this.color, this.darkMode}) : super(key: key);

  @override
  _AmbientPlayerState createState() => _AmbientPlayerState();
}

class _AmbientPlayerState extends State<AmbientPlayer>
    with WidgetsBindingObserver {
  Stream<QuerySnapshot> ambientMusic =
      Firestore.instance.collection('ambient').snapshots();
  // int _duration;
  String playingFileName;
  var connectivityType;
  var connectivityListener;
  bool connectivityWarningDisplayed = false;

  @override
  void initState() {
    super.initState();
    checkPlayingFile();
    WidgetsBinding.instance.addObserver(this);
    connect();
    connectivityListener = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityType = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    connectivityListener.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: WaveWidget(
            config: CustomConfig(
              blur: MaskFilter.blur(BlurStyle.solid, 5),
              colors: [
                widget.darkMode ? Colors.grey[850] : widget.color[400],
                widget.darkMode ? Colors.grey[800] : widget.color[300],
                widget.darkMode ? Colors.grey[700] : widget.color[200],
                widget.darkMode ? Colors.grey[600] : widget.color[100]
              ],
              durations: [35000, 19440, 10800, 6000],
              heightPercentages: [0.30, 0.33, 0.35, 0.40],
            ),
            backgroundColor: widget.darkMode ? Colors.grey[900] : Colors.white,
            size: Size(double.infinity, double.infinity),
            waveAmplitude: 0,
          ),
        ),
        Positioned.fill(
          top: 0,
          child: StreamBuilder(
              stream: AudioService.playbackStateStream,
              builder: (context, snapshot) {
                PlaybackState state = snapshot.data;
                return StreamBuilder<QuerySnapshot>(
                  stream: ambientMusic,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Text('Loading...');
                      default:
                        return SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 100),
                            child: Wrap(
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                return Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: 190,
                                  child: AmbientMusicCard(
                                    title: document['title'],
                                    color: widget.color,
                                    darkMode: widget.darkMode,
                                    play: playFromMediaId,
                                    pause: AudioService.pause,
                                    stop: AudioService.stop,
                                    isPlaying: state?.basicState ==
                                            BasicPlaybackState.playing ||
                                        AudioServiceBackground
                                                .state.basicState ==
                                            BasicPlaybackState.playing,
                                    // position: state?.currentPosition,
                                    // duration: _duration,
                                    fileName: document['file_name'],
                                    isActive: playingFileName ==
                                        document['file_name'],
                                    loading: state?.basicState ==
                                        BasicPlaybackState.buffering,
                                  ),
                                );
                              }).toList(),
                            ));
                    }
                  },
                );
              }),
        ),
      ],
    );
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

  void playFromMediaId(fileName, title) {
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
              playMedia(fileName, title);
              setState(() {
                connectivityWarningDisplayed = true;
              });
            },
            color: widget.color,
          )
        ],
      ).show();
    } else {
      playMedia(fileName, title);
    }
  }

  void playMedia(fileName, title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fileInfoJson = "{\"fileName\":\"" +
        fileName +
        "\",\"title\":\"" +
        title +
        "\",\"type\":\"ambient\"}";
    if (AudioService.playbackState == null ||
        AudioService.playbackState?.basicState == BasicPlaybackState.none ||
        AudioService.playbackState?.basicState == BasicPlaybackState.stopped) {
      AudioService.start(
        backgroundTask: backgroundTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Hustle Hub Player',
        androidNotificationIcon: 'mipmap/ic_launcher',
      ).then((response) {
        AudioService.playFromMediaId(fileInfoJson);
      });
    } else {
      AudioService.playFromMediaId(fileInfoJson);
    }
    await prefs.setString('playingFileName', fileName);
    setState(() {
      playingFileName = fileName;
    });
  }
}
