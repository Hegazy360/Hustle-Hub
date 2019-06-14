import 'dart:io';
import 'dart:async';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:daily_ad1/AmbientMusicCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AmbientPlayer extends StatefulWidget {
  final color;
  final darkMode;

  const AmbientPlayer({Key key, this.color, this.darkMode}) : super(key: key);

  @override
  _AmbientPlayerState createState() => _AmbientPlayerState();
}

class _AmbientPlayerState extends State<AmbientPlayer> {
  Stream<QuerySnapshot> ambientMusic =
      Firestore.instance.collection('ambient').snapshots();
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  Duration _duration;
  Duration _position;
  PlayerState _playerState = PlayerState.stopped;
  String playingFileName;
  AudioPlayerState audioPlayerState;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool loading = false;
  get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
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
          child: StreamBuilder<QuerySnapshot>(
            stream: ambientMusic,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
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
                              audioPlayer: audioPlayer,
                              play: _play,
                              pause: _pause,
                              stop: _stop,
                              isPlaying: _isPlaying,
                              position: _position,
                              duration: _duration,
                              fileName: document['file_name'],
                              isActive:
                                  playingFileName == document['file_name'],
                              loading: loading,
                            ),
                          );
                        }).toList(),
                      ));
              }
            },
          ),
        ),
      ],
    );
  }

  void _initAudioPlayer() {
    _durationSubscription =
        audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        audioPlayerState = state;
      });
    });
  }

  Future<int> _play(fileName) async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;

    final Directory tempDir = Directory.systemTemp;
    final String path = '${tempDir.path}/$fileName';
    final File file = File(path);
    setState(() {
      loading = true;
      playingFileName = fileName;
      _stop();
    });
    if (file.existsSync()) {
      final result = await audioPlayer.play(path, isLocal: true);
      if (result == 1)
        setState(() {
          _playerState = PlayerState.playing;
          loading = false;
        });

      return result;
    } else {
      final StorageReference ref =
          FirebaseStorage.instance.ref().child(fileName);
      await audioPlayer.play(await ref.getDownloadURL()).then((test) {
        setState(() {
          _playerState = PlayerState.playing;
          loading = false;
        });
      });
      final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
      await downloadTask.future;
    }

    return 0;
  }

  Future<int> _pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
