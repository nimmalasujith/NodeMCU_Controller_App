// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';


class Joystick extends StatefulWidget {
  final Function(String, int) onChanged;

  Joystick({required this.onChanged});

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset position = const Offset(0, 0);

  double getAngle(Offset pos) {
    if (pos.dx == 0 && pos.dy == 0) {
      setState(() {
        widget.onChanged("S", 0);
      });

      return 0;
    } // Avoid division by zero
    double angleInRadians = atan2(pos.dy, pos.dx);
    double angleInDegrees = angleInRadians * (180 / pi);
    if (angleInDegrees < 0) angleInDegrees += 360;

    int number = (360 - angleInDegrees).toInt();
    int oneVal = ((pos.dx / 10).abs() + (pos.dy / 10).abs()).toInt();
    if (oneVal > 10) oneVal = 10;
    int twoVal = ((pos.dx / 10).abs() + (pos.dy / 10).abs()) ~/ 2;
    if (twoVal > 10) twoVal = 10;
    if (number >= 337 && number < 360 || number >= 0 && number <= 23) {
      widget.onChanged("R", oneVal);
    } else if (number >= 24 && number <= 67) {
      widget.onChanged("FR", twoVal);
    } else if (number >= 68 && number <= 112) {
      widget.onChanged("F", oneVal);
    } else if (number >= 113 && number <= 157) {
      widget.onChanged("FL", twoVal);
    } else if (number >= 158 && number <= 202) {
      widget.onChanged("L", oneVal);
    } else if (number >= 203 && number <= 247) {
      widget.onChanged("BL", twoVal);
    } else if (number >= 248 && number <= 292) {
      widget.onChanged("B", oneVal);
    } else if (number >= 293 && number <= 337) {
      widget.onChanged("BR", twoVal);
    }
    return angleInDegrees;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        position = Offset(
          position.dx + details.delta.dx,
          position.dy + details.delta.dy,
        );

        if (position.distance > 100) {
          position = Offset.fromDirection(
            position.direction,
            100,
          );
        }
        getAngle(position);

      },
      onPanEnd: (details) {
          position = const Offset(0, 0);
          getAngle(position);
      },
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        // Joystick handle
        child: Center(
          child: Transform.translate(
            offset: position,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(
                Icons.circle,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RCCode extends StatefulWidget {
  const RCCode({super.key});

  @override
  State<RCCode> createState() => _RCCodeState();
}

class _RCCodeState extends State<RCCode> {
  final String code = '''#define ENA 14   // Enable/speed motors Right        GPIO14(D5)
#define ENB 12   // Enable/speed motors Left         GPIO12(D6)
#define IN_1 15  // L298N in1 motors Right           GPIO15(D8)
#define IN_2 13  // L298N in2 motors Right           GPIO13(D7)
#define IN_3 0   // L298N in3 motors Left            GPIO2(D4)
#define IN_4 2   // L298N in4 motors Left            GPIO0(D3)

#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

String cmd;        //String to store app command state.
int speedCar = 0;  // 0 - 255.
int speed_Coeff = 3;

const char* ssid = "nodeMCU Car";
ESP8266WebServer server(80);

void setup() {

  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(IN_1, OUTPUT);
  pinMode(IN_2, OUTPUT);
  pinMode(IN_3, OUTPUT);
  pinMode(IN_4, OUTPUT);

  Serial.begin(115200);

  // Connecting WiFi

  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid);

  IPAddress myIP = WiFi.softAPIP();
  Serial.print("192.168.4.1 ");
  Serial.println(myIP);

  // Starting WEB-server
  server.on("/", HTTP_handleRoot);
  server.onNotFound(HTTP_handleRoot);
  server.begin();
}

void goAhead() {

  digitalWrite(IN_1, LOW);
  digitalWrite(IN_2, HIGH);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, LOW);
  digitalWrite(IN_4, HIGH);
  analogWrite(ENB, speedCar);
}

void goBack() {

  digitalWrite(IN_1, HIGH);
  digitalWrite(IN_2, LOW);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, HIGH);
  digitalWrite(IN_4, LOW);
  analogWrite(ENB, speedCar);
}

void goRight() {

  digitalWrite(IN_1, HIGH);
  digitalWrite(IN_2, LOW);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, LOW);
  digitalWrite(IN_4, HIGH);
  analogWrite(ENB, speedCar);
}

void goLeft() {

  digitalWrite(IN_1, LOW);
  digitalWrite(IN_2, HIGH);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, HIGH);
  digitalWrite(IN_4, LOW);
  analogWrite(ENB, speedCar);
}

void goAheadRight() {

  digitalWrite(IN_1, LOW);
  digitalWrite(IN_2, HIGH);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, LOW);
  digitalWrite(IN_4, HIGH);
  analogWrite(ENB, speedCar / speed_Coeff);
}

void goAheadLeft() {

  digitalWrite(IN_1, LOW);
  digitalWrite(IN_2, HIGH);
  analogWrite(ENA, speedCar / speed_Coeff);

  digitalWrite(IN_3, LOW);
  digitalWrite(IN_4, HIGH);
  analogWrite(ENB, speedCar);
}

void goBackRight() {

  digitalWrite(IN_1, HIGH);
  digitalWrite(IN_2, LOW);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, HIGH);
  digitalWrite(IN_4, LOW);
  analogWrite(ENB, speedCar / speed_Coeff);
}

void goBackLeft() {

  digitalWrite(IN_1, HIGH);
  digitalWrite(IN_2, LOW);
  analogWrite(ENA, speedCar / speed_Coeff);

  digitalWrite(IN_3, HIGH);
  digitalWrite(IN_4, LOW);
  analogWrite(ENB, speedCar);
}

void stopRobot() {

  digitalWrite(IN_1, LOW);
  digitalWrite(IN_2, LOW);
  analogWrite(ENA, speedCar);

  digitalWrite(IN_3, LOW);
  digitalWrite(IN_4, LOW);
  analogWrite(ENB, speedCar);
}

void loop() {
  server.handleClient();
  cmd = server.arg("State");
  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, cmd);

  if (error) {
    Serial.print("Parsing failed: ");
    Serial.println(error.c_str());
    return;
  }

  String command = doc["cmd"];
  if (doc["v"] > 0) speedCar = map(doc["v"], 1, 10, 50, 255);
  else speedCar = 0;
  if (command == "F") goAhead();
  else if (command == "B") goBack();
  else if (command == "L") goLeft();
  else if (command == "R") goRight();
  else if (command == "FR") goAheadRight();
  else if (command == "FL") goAheadLeft();
  else if (command == "BR") goBackRight();
  else if (command == "BL") goBackLeft();
  else if (command == "S") stopRobot();
}

void HTTP_handleRoot(void) {

  if (server.hasArg("State")) {
    Serial.println(server.arg("State"));
  }
  server.send(200, "text/html", "");
  delay(1);
}
''';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                      ]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          Text(
                            " back  ",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Code copied to clipboard')),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black12),
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          Text(
                            " Copy Code",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: HighlightView(
                      code,
                      language: 'arduino',
                      // Specify the language for syntax highlighting

                      theme: githubTheme,
                      // You can choose a different theme
                      textStyle: TextStyle(fontSize: 16.0), // Set the font size
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
