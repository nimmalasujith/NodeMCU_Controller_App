// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nodemcu_controller/text.dart';

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  TextEditingController _controller = TextEditingController();
  String _receivedData = 'No data received';
  Future<void> _sendData(String data) async {
    try {
      var response = await http.get(Uri.parse('http://your-esp8266-ip-address/send?data=$data'));
      if (response.statusCode == 200) {
        setState(() {
          _receivedData = response.body;
        });
      } else {
        setState(() {
          _receivedData = 'Failed to send data';
        });
      }
    } catch (e) {
      setState(() {
        _receivedData = 'Error: $e';
      });
    }
  }

  Future<void> _getData() async {
    try {
      var response = await http.get(Uri.parse('http://your-esp8266-ip-address/receive'));
      if (response.statusCode == 200) {
        setState(() {
          _receivedData = response.body;
        });
      } else {
        setState(() {
          _receivedData = 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        _receivedData = 'Error: $e';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backButton(),
            Center(child: Text("This page is in Testing Mode.",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),)),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter data to send',
              ),
            ),
            ElevatedButton(
              onPressed: () => _sendData(_controller.text),
              child: Text('Send Data'),
            ),
            ElevatedButton(
              onPressed: _getData,
              child: Text('Get Data from ESP8266'),
            ),
            SizedBox(height: 20),
            Text('Received Data:'),
            Text(_receivedData),
          ],
        ),
      ),
    );
  }
}
