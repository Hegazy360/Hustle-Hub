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
    return Column(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('ambient').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return new Container(
                    height: 300,
                    color: widget.color,
                    child: ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return new Column(children: <Widget>[
                          Text(document['title']),
                          Text(document['description']),
                          AmbientMusicCard(
                              title: document['title'],
                              description: document['description'],
                              fileName: document['file_name'])
                        ]);
                      }).toList(),
                    ));
            }
          },
        ),
        Expanded(
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
        )
      ],
    );
  }
}

class AmbientFileCard {}
