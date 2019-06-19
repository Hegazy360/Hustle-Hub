import 'dart:async';
import 'package:flutter/material.dart';
import 'package:daily_ad1/PodcastCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PodcastPlayer extends StatefulWidget {
  final color;
  final darkMode;

  const PodcastPlayer({Key key, this.color, this.darkMode}) : super(key: key);

  @override
  _PodcastPlayerState createState() => _PodcastPlayerState();
}

class _PodcastPlayerState extends State<PodcastPlayer> {
  Stream<QuerySnapshot> podcasts =
      Firestore.instance.collection('podcasts').snapshots();

 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: podcasts,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100),
                child: Wrap(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: PodcastCard(
                        podcast: document,
                        color: widget.color,
                        darkMode: widget.darkMode,
                      ),
                    );
                  }).toList(),
                ));
        }
      },
    );
  }
}
