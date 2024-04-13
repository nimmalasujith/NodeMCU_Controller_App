// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:nodemcu_controller/terminal.dart';
import 'package:nodemcu_controller/text.dart';


import 'joy_stick.dart';
import 'line_by_line_cmd.dart';

final String baseUrl = 'http://192.168.4.1';

sendCommand(String cmd, int v) async {
  var data = {'cmd': cmd, 'v': v};
  try {
    var jsonData = jsonEncode(data);

    final response = await http.get(Uri.parse('${baseUrl}/?State=$jsonData'));

    if (response.statusCode == 200) {
      print('Command sent: $cmd');
    } else {
      print('Failed to send command: $cmd');
    }
  } catch (e) {
    print('Error sending command: $e');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RobotControlApp());
}

class RobotControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white.withOpacity(0.95)
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int itemCount = 3;
  List imageList = ["assets/img.png", "assets/img_1.png", "assets/img_1.png"];
  List headingList = ["Wifi Car", "Line by Line Cmd with Delay","Terminal"];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "NodeMCU Controller",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    1, // You can adjust this aspect ratio according to your need
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (index == 0)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RobotControlScreen()));
                    if (index == 1)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => lineByLineCmd()));
                    if (index == 2)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Terminal()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(3), // Adjust margin as needed
                    padding: EdgeInsets.all(10), // Adjust margin as needed
                    child: Column(
                      children: [
                        Expanded(child: Image.asset(imageList[index])),
                        Text(
                          headingList[index],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: itemCount, // Number of items in the grid
            )
          ],
        ),
      )),
    );
  }
}

class lineByLineCmdConvertor {
  final String heading;
  final String cmd;
  final int sec;

  lineByLineCmdConvertor({
    required this.heading,
    required this.cmd,
    required this.sec,
  });

  // Convert object to a map
  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'cmd': cmd,
      'sec': sec,
    };
  }

  // Create object from a map
  factory lineByLineCmdConvertor.fromJson(Map<String, dynamic> json) {
    return lineByLineCmdConvertor(
      heading: json['heading'],
      cmd: json['cmd'],
      sec: json['sec'],
    );
  }
}


class RobotControlScreen extends StatefulWidget {
  @override
  _RobotControlScreenState createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  bool _isButtonPressed = false;

  void _sendContinuousCommand(String command) {
    if (_isButtonPressed) {
      sendCommand(command, 150);
      Future.delayed(Duration(milliseconds: 100), () {
        _sendContinuousCommand(command);
      });
    } else {
      sendCommand('S', 0);
    }
  }

  String dir = "";
  int spd = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      sendCommand(dir, spd);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            backButton(),
            Text('Remote Controller -  Wifi'),
            InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => RCCode()));
              },
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('Code')),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(child: Center(child: Joystick(
            onChanged: (cmd, speed) {
              Future.delayed(Duration(milliseconds: 100), () {
                setState(() {
                  dir = cmd;
                  spd = speed;
                });
              });
            },
          ))),
          // SizedBox(
          //   height: screenHeight,
          //   width: screenHeight,
          //
          //   child: Table(
          //     defaultColumnWidth: FixedColumnWidth(50.0),
          //     children: [
          //       TableRow(
          //         children: [
          //           _buildCell(),
          //           _buildCell(),
          //           _buildCell(),
          //         ],
          //       ),
          //       TableRow(
          //         children: [
          //           _buildCell(),
          //           _buildCell(),
          //           _buildCell(),
          //         ],
          //       ),
          //       TableRow(
          //         children: [
          //           _buildCell(),
          //           _buildCell(),
          //           _buildCell(),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dir : $dir",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Speed : $spd",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // GestureDetector(
                //   onTapDown: (_) {
                //     setState(() {
                //       _isButtonPressed = true;
                //       _sendContinuousCommand('F');
                //     });
                //   },
                //   onTapUp: (_) {
                //     setState(() {
                //       _isButtonPressed = false;
                //     });
                //   },
                //   child: Icon(
                //     Icons.arrow_circle_up,
                //     size: 40,
                //   ),
                // ),
                // GestureDetector(
                //   onTapDown: (_) {
                //     setState(() {
                //       _isButtonPressed = true;
                //       _sendContinuousCommand('B');
                //     });
                //   },
                //   onTapUp: (_) {
                //     setState(() {
                //       _isButtonPressed = false;
                //     });
                //   },
                //   child: ElevatedButton(
                //     onPressed: null,
                //     child: Text('Forward'),
                //   ),
                // ),
                // GestureDetector(
                //   onTapDown: (_) {
                //     setState(() {
                //       _isButtonPressed = true;
                //       _sendContinuousCommand('R');
                //     });
                //   },
                //   onTapUp: (_) {
                //     setState(() {
                //       _isButtonPressed = false;
                //     });
                //   },
                //   child: ElevatedButton(
                //     onPressed: null,
                //     child: Text('Right'),
                //   ),
                // ),
                // GestureDetector(
                //   onTapDown: (_) {
                //     setState(() {
                //       _isButtonPressed = true;
                //       _sendContinuousCommand('L');
                //     });
                //   },
                //   onTapUp: (_) {
                //     setState(() {
                //       _isButtonPressed = false;
                //     });
                //   },
                //   child: ElevatedButton(
                //     onPressed: null,
                //     child: Text('Lift'),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
