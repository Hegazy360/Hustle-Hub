import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:flutter/material.dart';
import 'package:daily_ad1/AmbientMusicCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AmbientPlayer extends StatefulWidget {
  final color;
  final darkMode;

  const AmbientPlayer({Key key, this.color, this.darkMode}) : super(key: key);

  @override
  _AmbientPlayerState createState() => _AmbientPlayerState();
}

class _AmbientPlayerState extends State<AmbientPlayer>
    with AutomaticKeepAliveClientMixin {
  Stream<QuerySnapshot> ambientMusic =
      Firestore.instance.collection('ambient').snapshots();

  @override
  bool get wantKeepAlive => true;

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
                                fileName: document['file_name']),
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
}

class AmbientFileCard {}
