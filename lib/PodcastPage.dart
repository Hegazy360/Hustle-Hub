import 'package:flutter/material.dart';

class PodcastPage extends StatefulWidget {
  final podcast;

  const PodcastPage({
    Key key,
    this.podcast,
  }) : super(key: key);
  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
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
        body: Center(
          child: Text("Sample Text"),
        ),
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
