import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_ad1/AdviceCard.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:daily_ad1/YoutubePlayerContainer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-8400135927246890')
        .then((response) {
      myBanner
        ..load()
        ..show(
          anchorType: AnchorType.bottom,
        );
    });

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
            onSelectNotification: onSelectNotification)
        .then((response) async {
      await _showNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Motivation',
      home: Center(
        child: Container(
          child: DefaultTabController(
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
                    new AdviceCard(color: colors[index]),
                    new YoutubePlayerContainer(color: colors[index]),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          ),
    );
  }

  Future<void> _showNotification() async {
    var scheduledNotificationDateTime = Time(10, 0, 0);
    var response = await http.get("https://api.adviceslip.com/advice");
    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      String advice = responseJSON['slip']['advice'];
      var bigTextStyleInformation =
          BigTextStyleInformation(advice, htmlFormatBigText: true);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'Daily Motivation', 'Daily Advice', 'Sends you a daily advice.',
          style: AndroidNotificationStyle.BigText,
          styleInformation: bigTextStyleInformation,
          importance: Importance.Max,
          priority: Priority.High,
          ticker: 'ticker');
      var platformChannelSpecifics =
          NotificationDetails(androidPlatformChannelSpecifics, null);
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          0,
          'Your daily advice',
          advice,
          scheduledNotificationDateTime,
          platformChannelSpecifics);
    }
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  testDevices: <String>["E69FA5F1C4163C34800437316A07E39B"],
);

BannerAd myBanner = BannerAd(
  adUnitId: 'ca-app-pub-8400135927246890/4389923227',
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
);
