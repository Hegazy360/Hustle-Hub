import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:flutter/material.dart';
import 'package:daily_ad1/AmbientMusicCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: WaveWidget(
            config: CustomConfig(
              blur: MaskFilter.blur(BlurStyle.solid, 5),
              colors: [
                // widget.color[400],
                // widget.color[300],
                // widget.color[200],
                // widget.color[100]
                Colors.grey[900],
                Colors.grey[800],
                Colors.grey[700],
                Colors.grey[600]
              ],
              durations: [35000, 19440, 10800, 6000],
              heightPercentages: [0.30, 0.33, 0.35, 0.40],

            ),
            backgroundColor: Colors.grey[600],
            size: Size(double.infinity, double.infinity),
            waveAmplitude: 0,
          ),
        ),
        Positioned.fill(
          top: 0,
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('ambient').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 200,
                        child: AmbientMusicCard(
                            title: document['title'],
                            description: document['description'],
                            fileName: document['file_name']),
                      );
                    }).toList(),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}

class AmbientFileCard {}
