import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:flutter/material.dart';

//IDEAS ONCE NAVIGATED TO AMBIENT - DIM ALL THEME LIGHTS - INDIGO IS A GOOD EXAMPLE - TO SET THE MOOD YA KNOW

class AmbientPlayer extends StatefulWidget {
  final color;

  const AmbientPlayer({Key key, this.color}) : super(key: key);

  @override
  _AmbientPlayerState createState() => _AmbientPlayerState();
}

class _AmbientPlayerState extends State<AmbientPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: WaveWidget(
        config: CustomConfig(
          colors: [
            widget.color[400],
            widget.color[300],
            widget.color[200],
            widget.color[100]
          ],
          durations: [35000, 19440, 10800, 6000],
          heightPercentages: [0.40, 0.43, 0.45, 0.50],
        ),
        backgroundColor: widget.color,
        size: Size(double.infinity, double.infinity),
        waveAmplitude: 0,
      ),
    );
  }
}
