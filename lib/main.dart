import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_ad1/AdviceCard.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-8400135927246890')
        .then((response) {
      myBanner
        // typically this happens well before the ad is shown
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
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification).then((response) async {
              await _showNotification();
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Motivation',
      home: Center(
        child: Container(
          child: new AdviceCard(),
        ),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
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

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    // );
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  testDevices: <String>[
    "E69FA5F1C4163C34800437316A07E39B"
  ], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: 'ca-app-pub-8400135927246890/4389923227',
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
);
