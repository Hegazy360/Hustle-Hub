import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

class AdviceContainer extends StatefulWidget {
  const AdviceContainer({
    Key key,
    @required this.loading,
    @required this.advice,
    @required this.colors,
    @required this.index,
  }) : super(key: key);

  final bool loading;
  final String advice;
  final List colors;
  final int index;

  @override
  _AdviceContainerState createState() => _AdviceContainerState();
}

class _AdviceContainerState extends State<AdviceContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 130.0),
      child: Stack(
        children: <Widget>[
          SizedBox(
            width: 300.0,
            height: 180.0,
            child: Center(
              child: widget.loading
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        widget.advice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: widget.loading
                ? Text("")
                : GestureDetector(
                    onTap: () {
                      ClipboardManager.copyToClipBoard(widget.advice)
                          .then((result) {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Awesome!",
                          message:
                              "Copied to Clipboard",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      });
                    },
                    child: Icon(Icons.content_copy,
                        color: widget.colors[widget.index], size: 30),
                  ),
          )
        ],
      ),
    );
  }
}
