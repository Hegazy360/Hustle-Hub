import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_ad1/AdviceContainer.dart';
import 'package:daily_ad1/YoutubePlayerContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdviceCard extends StatefulWidget {
  @override
  _AdviceCardState createState() => _AdviceCardState();
}

class _AdviceCardState extends State<AdviceCard>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  bool firstAdvice = true;
  String advice = "";
  List colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
  ];
  Random random = new Random();
  int index = 0;
  AnimationController _controller;
  Animation<double> _frontScale;
  List youtubeList = [];

  fetchAdvice() async {
    var response = await http.get("https://api.adviceslip.com/advice");
    setState(() {
      _controller.forward(from: 0.0);
      loading = true;
    });
    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);

      setState(() {
        if (!firstAdvice) index = random.nextInt(7);
        advice = responseJSON['slip']['advice'];
      });
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
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

  @override
  void initState() {
    super.initState();
    fetchAdvice();
    fetchYoutubeList();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _frontScale = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.0, 1.0, curve: Curves.ease),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed)
          setState(() {
            loading = false;
          });
      }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: colors[index],
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.lightbulb_outline),
                  text: "Advice",
                ),
                Tab(
                  icon: Icon(Icons.play_circle_outline),
                  text: "Motivational Videos",
                ),
              ],
            ),
            centerTitle: true,
            elevation: 0,
            title: Text('Looking for guidance?'),
          ),
          body: TabBarView(
            children: [
              AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: colors[index],
                  alignment: Alignment(0.0, 0.0),
                  child: Column(
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _controller,
                        child: new AdviceContainer(
                            loading: loading,
                            advice: advice,
                            colors: colors,
                            index: index),
                        builder: (BuildContext context, Widget child) {
                          return Transform(
                            transform: Matrix4.rotationX(
                                !firstAdvice ? _frontScale.value * pi : 0),
                            alignment: Alignment.center,
                            origin: Offset(0, 70.0),
                            child: child,
                          );
                        },
                      ),
                      Container(
                        margin: EdgeInsets.all(30.0),
                        height: 50,
                        width: 150,
                        child: RaisedButton.icon(
                          icon: Container(
                            child: Icon(Icons.refresh, color: colors[index]),
                          ),
                          label: Text('Another one!'),
                          color: Colors.white,
                          splashColor: colors[index],
                          onPressed: () {
                            if (firstAdvice) {
                              setState(() {
                                firstAdvice = false;
                              });
                            }
                            fetchAdvice();
                          },
                        ),
                      ),
                    ],
                  )),
              new YoutubePlayerContainer(
                  youtubeList: youtubeList, color: colors[index]),
            ],
          ),
        ));
  }
}
