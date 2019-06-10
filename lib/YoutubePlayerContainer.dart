import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_admob/firebase_admob.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerContainer extends StatefulWidget {
  final color;

  const YoutubePlayerContainer({Key key, this.color}) : super(key: key);

  @override
  _YoutubePlayerContainerState createState() => _YoutubePlayerContainerState();
}

class _YoutubePlayerContainerState extends State<YoutubePlayerContainer>
    with AutomaticKeepAliveClientMixin {
  YoutubePlayerController _controller = YoutubePlayerController();
  ScrollController _scrollController;
  List youtubeList = [];
  bool autoPlay = false;
  bool firstVideo = true;
  bool lastVideo = false;
  var index = 0;

  @override
  bool get wantKeepAlive => true;

  void listener() {
    if (_controller.value.playerState == PlayerState.ENDED) {
      myInterstitial
        ..load()
        ..show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
        );
      if (!lastVideo)
        setState(() {
          var newIndex = index + 1;
          if (firstVideo) firstVideo = false;
          if (newIndex == youtubeList.length - 1) lastVideo = true;
          index++;
        });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    fetchYoutubeList();
    _scrollController = new ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        youtubeList.length > 0
            ? Container(
                child: YoutubePlayer(
                  autoPlay: autoPlay,
                  context: context,
                  videoId: youtubeList[index]['videoId'],
                  thumbnailUrl: youtubeList[index]['thumbnail_hd'],
                  onPlayerInitialized: (controller) {
                    _controller = controller;
                    _controller.addListener(listener);
                  },
                ),
              )
            : CircularProgressIndicator(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton.icon(
                icon: Container(
                  child: Icon(Icons.navigate_before, color: widget.color),
                ),
                label: Text('Previous Video'),
                color: Colors.white,
                splashColor: widget.color,
                onPressed: firstVideo
                    ? null
                    : () {
                        myInterstitial
                          ..load()
                          ..show(
                            anchorType: AnchorType.bottom,
                            anchorOffset: 0.0,
                          );
                        setState(() {
                          var newIndex = index - 1;
                          if (!autoPlay) autoPlay = true;
                          if (lastVideo) lastVideo = false;
                          if (newIndex == 0) firstVideo = true;
                          index = newIndex;
                        });
                      },
              ),
              RaisedButton.icon(
                icon: Container(
                  child: Icon(Icons.navigate_next, color: widget.color),
                ),
                label: Text('Next Video'),
                color: Colors.white,
                splashColor: widget.color,
                onPressed: lastVideo
                    ? null
                    : () {
                        _scrollController.animateTo(index.toDouble() * 101,
                            duration: new Duration(seconds: 1),
                            curve: Curves.ease);
                        myInterstitial
                          ..load()
                          ..show(
                            anchorType: AnchorType.bottom,
                            anchorOffset: 0.0,
                          );
                        setState(() {
                          var newIndex = index + 1;
                          if (!autoPlay) autoPlay = true;
                          if (firstVideo) firstVideo = false;
                          if (newIndex == youtubeList.length - 1)
                            lastVideo = true;
                          index++;
                        });
                      },
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            itemCount: youtubeList.length,
            itemBuilder: (context, position) {
              return GestureDetector(
                  onTap: (() {
                    myInterstitial
                      ..load()
                      ..show(
                        anchorType: AnchorType.bottom,
                        anchorOffset: 0.0,
                      );
                    setState(() {
                      index = position;
                      firstVideo = position == 0;
                      lastVideo = position == youtubeList.length - 1;
                    });
                  }),
                  child: Card(
                    color: position == index ? widget.color : Colors.white,
                    child: Row(
                      children: <Widget>[
                        Image.network(
                          youtubeList[position]['thumbnail'],
                        ),
                        Flexible(
                            child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            youtubeList[position]['title'],
                            style: TextStyle(
                                color: position == index
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ))
                      ],
                    ),
                  ));
            },
          ),
        )
      ],
    );
  }

  fetchYoutubeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var youtubeListString = prefs.getString('youtubeListString');

    if (youtubeListString != null) {
      Map youtubeListResponse = json.decode(youtubeListString);
      setState(() {
        youtubeList = getVideoIdsList(youtubeListResponse);
      });
    } else {
      var response = await http.get(
          "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&type=video&q=motivation+video&fields=items(id/videoId,snippet(title,liveBroadcastContent,thumbnails))&key=AIzaSyAoUNaKj8v5naEie7Caw0ujDkxvY6VXvz0");
      if (response.statusCode == 200) {
        Map youtubeListResponse = json.decode(response.body);
        setState(() {
          youtubeList = getVideoIdsList(youtubeListResponse);
        });
        await prefs.setString('youtubeListString', response.body);
      } else {
        print('Something went wrong. \nResponse Code : ${response.statusCode}');
      }
    }
  }

  List getVideoIdsList(Map youtubeListResponse) {
    List videoIdsList = [];

    for (var youtubeVideo in youtubeListResponse['items']) {
      if (youtubeVideo['snippet']['liveBroadcastContent'] == 'none')
        videoIdsList.add({
          'videoId': youtubeVideo['id']['videoId'],
          'title': youtubeVideo['snippet']['title'],
          'thumbnail': youtubeVideo['snippet']['thumbnails']['default']['url'],
          'thumbnail_hd': youtubeVideo['snippet']['thumbnails']['high']['url'],
        });
    }

    return videoIdsList;
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  testDevices: <String>["E69FA5F1C4163C34800437316A07E39B"],
);

InterstitialAd myInterstitial = InterstitialAd(
  adUnitId: "ca-app-pub-8400135927246890/7657308297",
  targetingInfo: targetingInfo,
);
