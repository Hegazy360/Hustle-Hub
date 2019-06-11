import 'dart:io';
import 'dart:async';
import 'package:audio/audio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String filePath;
  Audio audioPlayer = new Audio(single: true);
  AudioPlayerState state = AudioPlayerState.STOPPED;
  double position = 0;
  int buffering = 0;
  StreamSubscription<AudioPlayerState> _playerStateSubscription;
  StreamSubscription<double> _playerPositionController;
  StreamSubscription<int> _playerBufferingSubscription;
  StreamSubscription<AudioPlayerError> _playerErrorSubscription;

  @override
  void initState() {
    downloadFile(widget.fileName);
    _playerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      print("onPlayerStateChanged: ${audioPlayer.uid} $state");

      if (mounted) setState(() => this.state = state);
    });

    _playerPositionController =
        audioPlayer.onPlayerPositionChanged.listen((double position) {
      print(
          "onPlayerPositionChanged: ${audioPlayer.uid} $position ${audioPlayer.duration}");

      if (mounted) setState(() => this.position = position);
    });

    _playerBufferingSubscription =
        audioPlayer.onPlayerBufferingChanged.listen((int percent) {
      print("onPlayerBufferingChanged: ${audioPlayer.uid} $percent");

      if (mounted && buffering != percent) setState(() => buffering = percent);
    });

    _playerErrorSubscription =
        audioPlayer.onPlayerError.listen((AudioPlayerError error) {
      throw ("onPlayerError: ${error.code} ${error.message}");
    });

    audioPlayer.preload(filePath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget status = Container();

    print(
        "[build] uid=${audioPlayer.uid} duration=${audioPlayer.duration} state=$state");

    switch (state) {
      case AudioPlayerState.LOADING:
        {
          status = Container(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 24.0,
                height: 24.0,
                child: Center(
                    child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    CircularProgressIndicator(strokeWidth: 2.0),
                    Text("${buffering}%",
                        style: TextStyle(fontSize: 8.0),
                        textAlign: TextAlign.center)
                  ],
                )),
              ));
          break;
        }

      case AudioPlayerState.PLAYING:
        {
          status = IconButton(
              icon: Icon(Icons.pause, size: 28.0), onPressed: onPause);
          break;
        }

      case AudioPlayerState.READY:
      case AudioPlayerState.PAUSED:
      case AudioPlayerState.STOPPED:
        {
          status = IconButton(
              icon: Icon(Icons.play_arrow, size: 28.0), onPressed: onPlay);

          if (state == AudioPlayerState.STOPPED) audioPlayer.seek(0.0);

          break;
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        children: <Widget>[
          Text(audioPlayer.uid),
          Row(
            children: <Widget>[
              status,
              Slider(
                max: audioPlayer.duration.toDouble(),
                value: position.toDouble(),
                onChanged: onSeek,
              ),
              Text("${audioPlayer.duration.toDouble()}ms")
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _playerPositionController.cancel();
    _playerBufferingSubscription.cancel();
    _playerErrorSubscription.cancel();
    audioPlayer.release();
    super.dispose();
  }

  onPlay() {
    audioPlayer.play("https://firebasestorage.googleapis.com/v0/b/daily-ad1.appspot.com/o/SampleAudio_0.4mb.mp3?alt=media&token=ba0eefbc-83d8-4064-b9d1-5c9c52e5da34");
  }

  onPause() {
    audioPlayer.pause();
  }

  onSeek(double value) {
    // Note: We can only seek if the audio is ready
    audioPlayer.seek(value);
  }

  Future<Null> downloadFile(String httpPath) async {
    final RegExp regExp = RegExp('([^?/]*\.(mp3))');
    final String fileName = regExp.stringMatch(httpPath);
    final Directory tempDir = Directory.systemTemp;
    final String path = '${tempDir.path}/$fileName';
    final File file = File(path);
    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
    final int byteNumber = (await downloadTask.future).totalByteCount;

    print('HERE BRO WE GUCCI');

    print(byteNumber);
    print(path);

    if (mounted) setState(() => filePath = path);
  }
}
