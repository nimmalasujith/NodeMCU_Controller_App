import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:async';


class TimeProgressDemo extends StatefulWidget {
  int sec;
  TimeProgressDemo({required this.sec});
  @override
  _TimeProgressDemoState createState() => _TimeProgressDemoState();
}

class _TimeProgressDemoState extends State<TimeProgressDemo> {
  Timer? timer;

  double _progressValue = 1.0;
  late int _durationInSeconds ;

  void start() {
    int seconds=widget.sec;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
      } else {
        seconds--;
        setState(() {
          _progressValue = (seconds/widget.sec);
        });

        print('$seconds seconds left');
      }
    });
  }

  void stop() {
    if (timer != null) {
      timer?.cancel();
    }
  }




  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: 2,
      value: 1-_progressValue,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }
}
class backButton extends StatefulWidget {

  @override
  State<backButton> createState() => _backButtonState();
}

class _backButtonState extends State<backButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3,horizontal: 10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(15)),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.arrow_back,color: Colors.white,size: 18,),
            Text(" back ",style: TextStyle(
                color: Colors.white,
                fontSize: 15
            ),),
          ],),
      ),
    );
  }
}
