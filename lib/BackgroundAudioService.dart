import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

void backgroundTask() {
  AudioPlayer audioPlayer = new AudioPlayer();
  Completer completer = Completer();
  int position;
  // int duration;

  void _setPlayingState(resetPosition) {
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      basicState: BasicPlaybackState.playing,
      position: position == null || resetPosition ? 0 : position,
    );
  }

  void resume() {
    audioPlayer.resume();
    if (position == null) {
      AudioServiceBackground.setState(
        controls: [stopControl],
        basicState: BasicPlaybackState.connecting,
        position: 0,
      );
    } else {
      _setPlayingState(false);
    }
  }

  void pause() {
    audioPlayer.pause();
    AudioServiceBackground.setState(
      controls: [playControl, stopControl],
      basicState: BasicPlaybackState.paused,
      position: position,
    );
  }

  void stop() {
    audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    completer.complete();
  }

  Future<void> run() async {
    var playerStateSubscription = audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });

    var audioPositionSubscription =
        audioPlayer.onAudioPositionChanged.listen((when) {
      final connected = position == null;
      position = when.inMilliseconds;
      if (connected) {
        _setPlayingState(false);
      }
    });
    await completer.future;
    playerStateSubscription.cancel();
    audioPositionSubscription.cancel();
  }

  Future<String> _downloadFile(String url2, String filename) async {
    var url = url2;

    var isRedirect = true;

    while (isRedirect) {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = false;
      final response = await client.send(request);
      print(response.statusCode);
      if (response.statusCode == HttpStatus.movedTemporarily) {
        isRedirect = response.isRedirect;
        url = response.headers['location'];
      } else if (response.statusCode == HttpStatus.ok) {
        return url;
      }
    }
  }

  AudioServiceBackground.run(
    onStart: run,
    onPlay: resume,
    onPause: pause,
    onStop: stop,
    onPlayFromMediaId: (String fileInfoJson) async {
      var fileInfo = json.decode(fileInfoJson);
      var fileName = fileInfo['fileName'];
      var title = fileInfo['title'];

      MediaItem mediaItem = MediaItem(
        id: fileName,
        artist: 'Ambient Music',
        album: 'Ambient Music',
        title: title,
      );
      AudioServiceBackground.setMediaItem(mediaItem);
      AudioServiceBackground.setState(
        controls: [stopControl],
        basicState: BasicPlaybackState.buffering,
        position: 0,
      );

      if (fileInfo['type'] == 'ambient') {
        final Directory directory = await getApplicationDocumentsDirectory();
        final String path = '${directory.path}/$fileName';
        final File file = File(path);
        if (file.existsSync()) {
          await audioPlayer.play(path, isLocal: true).then((response) {
            _setPlayingState(true);
          });
        } else {
          final StorageReference ref =
              FirebaseStorage.instance.ref().child(fileName);

          final StorageFileDownloadTask downloadTask = ref.writeToFile(file);
          await downloadTask.future.then((value) async {
            await audioPlayer.play(path, isLocal: true).then((response) {
              _setPlayingState(true);
            });
          });
        }
      } else {
        await _downloadFile(fileInfo['audioUrl'], fileName).then((path) async {
          await audioPlayer.play(path).then((response) {
            _setPlayingState(true);
          });
        });
      }
    },
    onClick: (MediaButton button) {
      if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
        pause();
      else
        resume();
    },
  );
}
