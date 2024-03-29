import 'package:flutter/material.dart';
import 'package:daily_ad1/PodcastPage.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum PlayerState { stopped, playing, paused }

class PodcastCard extends StatefulWidget {
  final podcast;
  // final fileName;
  final color;
  final darkMode;
  // final pause;
  // final stop;
  // final isPlaying;
  // final position;
  // final duration;
  // final isActive;
  // final loading;

  const PodcastCard(
      {Key key,
      this.podcast,
      this.color,
      this.darkMode,
      // this.fileName,
      // this.pause,
      // this.stop,
      // this.isPlaying,
      // this.position,
      // this.duration,
      // this.isActive,
      // this.loading
      })
      : super(key: key);

  @override
  _PodcastCardState createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return PodcastPage(
                  podcast: widget.podcast,
                  color: widget.color,
                  darkMode: widget.darkMode
                );
              },
              fullscreenDialog: true));
        },
        child: Hero(
            tag: widget.podcast['listennotes_id'],
            child: Card(
                color: widget.darkMode? Colors.grey[900] : Colors.white,
                child: Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 20, top: 20, bottom: 20, right: 7),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text(
                                widget.podcast['title'],
                                style: TextStyle(
                                    color: widget.darkMode? Colors.white :widget.color,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              )),
                          Container(
                            child: Text(
                              widget.podcast['description'],
                              style:
                                  TextStyle(color: widget.darkMode? Colors.white : Colors.black, fontSize: 15),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                Container(
                  height: 110,
                  margin: EdgeInsets.only(top: 5, right: 5, bottom: 5),
                  child: CachedNetworkImage(
                    imageUrl: widget.podcast['thumbnail_url'],
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                )
              ],
            ))));
  }
}
