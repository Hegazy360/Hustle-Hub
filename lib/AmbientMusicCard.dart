import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class AmbientMusicCard extends StatefulWidget {
  final title;
  final fileName;
  final color;
  final darkMode;
  final play;
  final pause;
  final stop;
  final isPlaying;
  // final position;
  // final duration;
  final isActive;
  final loading;

  const AmbientMusicCard(
      {Key key,
      this.title,
      this.fileName,
      this.color,
      this.darkMode,
      this.play,
      this.pause,
      this.stop,
      this.isPlaying,
      // this.position,
      // this.duration,
      this.isActive,
      this.loading})
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
  Widget build(BuildContext context) {
    return Card(
        color: widget.isPlaying && widget.isActive
            ? widget.darkMode
                ? Colors.grey[900].withOpacity(0.4)
                : widget.color.withOpacity(0.4)
            : widget.darkMode ? Colors.black12 : Colors.white10,
        child: Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
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
                          widget.isActive && widget.loading
                              ? Padding(
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation(
                                        widget.darkMode
                                            ? Colors.grey[600]
                                            : widget.color),
                                  ))
                              : IconButton(
                                  onPressed: () =>
                                      widget.isPlaying && widget.isActive
                                          ? widget.pause()
                                          : widget.play(
                                              widget.fileName, widget.title),
                                  iconSize: 80.0,
                                  icon: widget.isPlaying && widget.isActive
                                      ? Icon(Icons.pause)
                                      : Icon(Icons.play_arrow),
                                  color: Colors.white),
                        ],
                      ),
                      Stack(
                        children: <Widget>[
                          // LinearProgressIndicator(
                          //   value: (widget.isActive &&
                          //           widget.position != null &&
                          //           widget.duration != null &&
                          //           widget.position > 0 &&
                          //           widget.position <
                          //               widget.duration)
                          //       ? widget.position /
                          //           widget.duration
                          //       : 0.0,
                          //   valueColor: AlwaysStoppedAnimation(widget.darkMode
                          //       ? Colors.white
                          //       : widget.color[200]),
                          //   backgroundColor:
                          //       widget.darkMode ? Colors.orange : Colors.white,
                          // ),
                          widget.isPlaying && widget.isActive
                              ? Positioned(
                                  child: WaveWidget(
                                  config: CustomConfig(
                                    blur: MaskFilter.blur(BlurStyle.solid, 5),
                                    colors: [
                                      widget.darkMode
                                          ? Colors.grey[850]
                                          : Colors.white10,
                                      widget.darkMode
                                          ? Colors.grey[800]
                                          : Colors.white12,
                                      widget.darkMode
                                          ? Colors.grey[700]
                                          : Colors.white24,
                                      widget.darkMode
                                          ? Colors.grey[600]
                                          : Colors.white30
                                    ],
                                    durations: [55000, 39440, 30800, 8000],
                                    heightPercentages: [0.10, 0.13, 0.15, 0.20],
                                  ),
                                  size: Size(double.infinity, 10.0),
                                  waveAmplitude: 0,
                                ))
                              : Container()
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
