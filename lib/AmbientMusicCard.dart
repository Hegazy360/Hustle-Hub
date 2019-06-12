import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum PlayerState { stopped, playing, paused }

class AmbientMusicCard extends StatefulWidget {
  final title;
  final description;
  final fileName;

  const AmbientMusicCard({Key key, this.title, this.description, this.fileName})
      : super(key: key);

  @override
  _AmbientMusicCardState createState() => _AmbientMusicCardState();
}

class _AmbientMusicCardState extends State<AmbientMusicCard> {
  bool isLocal;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.black38,
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.indigo[50], fontSize: 20, fontWeight: FontWeight.w300),
                ),
                IconButton(
                    onPressed: () =>
                        _isPlaying ? _pause() : _play(widget.fileName),
                    iconSize: 100.0,
                    icon:
                        _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    color: Colors.indigo[100]),
              ],
            )));
    // return Row(
    //   mainAxisSize: MainAxisSize.min,
    //   children: <Widget>[
    //     Column(
    //       children: [
    //         IconButton(
    //             onPressed: _isPlaying ? null : () => _play(widget.fileName),
    //             iconSize: 64.0,
    //             icon: Icon(Icons.play_arrow),
    //             color: Colors.cyan),
    //         IconButton(
    //             onPressed: _isPlaying ? () => _pause() : null,
    //             iconSize: 64.0,
    //             icon: Icon(Icons.pause),
    //             color: Colors.cyan),
    //         IconButton(
    //             onPressed: _isPlaying || _isPaused ? () => _stop() : null,
    //             iconSize: 64.0,
    //             icon: Icon(Icons.stop),
    //             color: Colors.cyan),
    //       ],
    //     ),
    //     Column(
    //       children: [
    //         Padding(
    //           padding: EdgeInsets.all(12.0),
    //           child: Stack(
    //             children: [
    //               CircularProgressIndicator(
    //                 value: 1.0,
    //                 valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
    //               ),
    //               CircularProgressIndicator(
    //                 value: (_position != null &&
    //                         _duration != null &&
    //                         _position.inMilliseconds > 0 &&
    //                         _position.inMilliseconds < _duration.inMilliseconds)
    //                     ? _position.inMilliseconds / _duration.inMilliseconds
    //                     : 0.0,
    //                 valueColor: AlwaysStoppedAnimation(Colors.cyan),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Text(
    //           _position != null
    //               ? '${_positionText ?? ''} / ${_durationText ?? ''}'
    //               : _duration != null ? _durationText : '',
    //           style: TextStyle(fontSize: 24.0),
    //         ),
    //       ],
    //     ),
    //     Text("State: $_audioPlayerState")
    //   ],
    // );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) => setState(() {
              _duration = duration;
            }));

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
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
    if (file.existsSync()) {
      final result =
          await _audioPlayer.play(path, isLocal: true, position: playPosition);
      if (result == 1) setState(() => _playerState = PlayerState.playing);
      return result;
    } else {
      final StorageReference ref =
          FirebaseStorage.instance.ref().child(fileName);
      final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
      await downloadTask.future.then((test) async {
        final result = await _audioPlayer.play(path,
            isLocal: true, position: playPosition);
        if (result == 1) setState(() => _playerState = PlayerState.playing);
        return result;
      });
    }

    return 0;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  Future<String> downloadFile(fileName) async {}
}
