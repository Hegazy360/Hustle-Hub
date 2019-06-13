import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class AmbientMusicCard extends StatefulWidget {
  final title;
  final fileName;
  final color;
  final darkMode;
  final audioPlayer;
  final play;
  final pause;
  final stop;
  final isPlaying;
  final position;
  final duration;
  final isActive;

  const AmbientMusicCard(
      {Key key,
      this.title,
      this.fileName,
      this.color,
      this.darkMode,
      this.audioPlayer,
      this.play,
      this.pause,
      this.stop,
      this.isPlaying,
      this.position,
      this.duration,
      this.isActive})
      : super(key: key);

  @override
  _AmbientMusicCardState createState() => _AmbientMusicCardState();
}

class _AmbientMusicCardState extends State<AmbientMusicCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    widget.audioPlayer.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    widget.audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: widget.isPlaying && widget.isActive
            ? widget.darkMode
                ? Colors.grey[900].withOpacity(0.4)
                : widget.color.withOpacity(0.4)
            : Colors.white12,
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                              onPressed: () =>
                                  widget.isPlaying && widget.isActive
                                      ? widget.pause()
                                      : widget.play(widget.fileName),
                              iconSize: 80.0,
                              icon: widget.isPlaying && widget.isActive
                                  ? Icon(Icons.pause)
                                  : Icon(Icons.play_arrow),
                              color: Colors.white),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          LinearProgressIndicator(
                            value: (widget.isActive &&
                                    widget.position != null &&
                                    widget.duration != null &&
                                    widget.position.inMilliseconds > 0 &&
                                    widget.position.inMilliseconds <
                                        widget.duration.inMilliseconds)
                                ? widget.position.inMilliseconds /
                                    widget.duration.inMilliseconds
                                : 0.0,
                            valueColor: AlwaysStoppedAnimation(
                                widget.darkMode ? Colors.white : widget.color),
                            backgroundColor:
                                widget.darkMode ? Colors.orange : Colors.white,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
