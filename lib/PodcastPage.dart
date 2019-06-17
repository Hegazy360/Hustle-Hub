import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:expandable/expandable.dart';
import 'package:flutter_html/flutter_html.dart';

class PodcastPage extends StatefulWidget {
  final podcast;
  final play;

  const PodcastPage({
    Key key,
    this.podcast,
    this.play,
  }) : super(key: key);

  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  List episodes = [];
  bool isLoading = false;

  @override
  void initState() {
    getEpisodes();
    super.initState();
  }

  void getEpisodes() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.get(
      'https://listen-api.listennotes.com/api/v2/podcasts/${widget.podcast['listennotes_id']}?sort=recent_first',
      // Send authorization headers to the backend.
      headers: {'X-ListenAPI-Key': "af3f605216fd4033bb545e9beaf14196"},
    );
    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      print(responseJSON['episodes']);
      setState(() {
        isLoading = false;
        episodes = responseJSON['episodes'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 80),
                child: Hero(
                    tag: widget.podcast['listennotes_id'],
                    child: Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(
                                          bottom: 10, right: 10),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        widget.podcast['title'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                    height: 110,
                                    margin: EdgeInsets.only(
                                        top: 5, right: 5, bottom: 5, left: 5),
                                    child: Image.network(
                                      widget.podcast['thumbnail_url'],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(
                                widget.podcast['description'],
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ))),
              ),
            ),
          ];
        },
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: episodes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 100,
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              size: 60,
                            ),
                            onPressed: () {
                              widget.play(episodes[index]['id'],
                                  episodes[index]['title'], episodes[index]['audio']);
                            },
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ExpandablePanel(
                                header: Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      episodes[index]['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )),
                                collapsed: Container(
                                    height: 55,
                                    child: Html(
                                      data: episodes[index]['description'],
                                      defaultTextStyle: TextStyle(fontSize: 15),
                                    ))
                                // Text(
                                //   Html(data: episodes[index]['description']),
                                //   softWrap: true,
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                // )
                                ,
                                expanded: Container(
                                    child: Html(
                                  data: episodes[index]['description'],
                                  defaultTextStyle: TextStyle(fontSize: 15),
                                )
                                    // Text(
                                    //   article.body,
                                    //   softWrap: true,
                                    // )
                                    ),
                                tapHeaderToExpand: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
    // return MaterialApp(
    //   title: 'Hustle Hub',
    //   home: Center(
    //     child: Container(
    //       child: DefaultTabController(
    //           length: 4,
    //           child: Scaffold(
    //             appBar: AppBar(
    //               backgroundColor: Colors.grey[900],
    //               centerTitle: true,
    //               elevation: 0,
    //               title: Text('Hustle Hub'),
    //             ),
    //             body: Container(
    //               color: Colors.white,
    //               child: Column(
    //                 children: <Widget>[
    //                   Container(
    //                     child: Hero(
    //                         tag: widget.podcast['listennotes_id'],
    //                         child: Card(
    //                             child: Row(
    //                           children: <Widget>[
    //                             Padding(
    //                                 padding: EdgeInsets.only(
    //                                     left: 20,
    //                                     top: 20,
    //                                     bottom: 20,
    //                                     right: 7),
    //                                 child: Container(
    //                                   width: MediaQuery.of(context).size.width *
    //                                       0.6,
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.start,
    //                                     children: <Widget>[
    //                                       Container(
    //                                           margin:
    //                                               EdgeInsets.only(bottom: 10),
    //                                           child: Text(
    //                                             widget.podcast['title'],
    //                                             style: TextStyle(
    //                                                 color: Colors.black,
    //                                                 fontSize: 17,
    //                                                 fontWeight:
    //                                                     FontWeight.bold),
    //                                           )),
    //                                       Container(
    //                                         child: Text(
    //                                           widget.podcast['description'],
    //                                           style: TextStyle(
    //                                               color: Colors.black,
    //                                               fontSize: 15),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 )),
    //                             Container(
    //                               height: 110,
    //                               margin: EdgeInsets.only(
    //                                   top: 5, right: 5, bottom: 5),
    //                               child: Image.network(
    //                                 widget.podcast['thumbnail_url'],
    //                               ),
    //                             )
    //                           ],
    //                         ))),
    //                   )

    //                   // Row(
    //                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   //   children: <Widget>[
    //                   //     Container(child: Text("test")),
    //                   //     Container(
    //                   //       height: 150,
    //                   //       margin:
    //                   //           EdgeInsets.only(top: 5, right: 5, bottom: 5),
    //                   //       child: Hero(
    //                   //           tag: widget.podcast['listennotes_id'],
    //                   //           child: Image.network(
    //                   //             widget.podcast['thumbnail_url'],
    //                   //           )),
    //                   //     ),
    //                   //   ],
    //                   // )
    //                 ],
    //               ),
    //             ),
    //           )),
    //     ),
    //   ),
    // );
  }
}
