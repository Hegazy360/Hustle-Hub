import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daily_ad1/AdviceContainer.dart';

class AdviceCard extends StatefulWidget {
  final color;
  final generateColor;

  const AdviceCard({Key key, this.color, this.generateColor}) : super(key: key);

  @override
  _AdviceCardState createState() => _AdviceCardState();
}

class _AdviceCardState extends State<AdviceCard>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  bool firstAdvice = true;
  String advice = "";
  AnimationController _controller;
  Animation<double> _frontScale;

  fetchAdvice() async {
    var response = await http.get("https://api.adviceslip.com/advice");
    if (this.mounted) {
      setState(() {
        _controller.forward(from: 0.0);
        loading = true;
      });
    }

    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      if (this.mounted) {
        setState(() {
          if (!firstAdvice) widget.generateColor();
          advice = responseJSON['slip']['advice'];
        });
      }
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAdvice();
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
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: widget.color,
        alignment: Alignment(0.0, 0.0),
        child: Column(
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              child: new AdviceContainer(
                  loading: loading, advice: advice, color: widget.color),
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
                  child: Icon(Icons.refresh, color: widget.color),
                ),
                label: Text('Another one!'),
                color: Colors.white,
                splashColor: widget.color,
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
        ));
  }
}
