import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nodemcu_controller/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class lineByLineCmd extends StatefulWidget {
  const lineByLineCmd({super.key});

  @override
  State<lineByLineCmd> createState() => _lineByLineCmdState();
}

class _lineByLineCmdState extends State<lineByLineCmd> {
  final TextEditingController headingController = TextEditingController();
  final TextEditingController commandController = TextEditingController();
  final TextEditingController secondsController = TextEditingController();
  int currentIndex = 0;
  bool _isPlay = false;
   List<lineByLineCmdConvertor> items = [];


  @override
  void initState() {
    super.initState();
    loadItems();
  }

  loadItems() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    List<String>? itemsJson = prefs.getStringList('items');
    if (itemsJson != null) {
      setState(() {
        items.clear();
        items.addAll(itemsJson.map((item) => lineByLineCmdConvertor.fromJson(json.decode(item))));
      });
    }
  }

  saveItems() async {
    SharedPreferences prefs;
    prefs = await SharedPreferences.getInstance();
    List<String> itemsJson = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('items', itemsJson);
    loadItems();
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    saveItems();
  }
  sendCommand(String cmd) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/?State=$cmd'));

      if (response.statusCode == 200) {
        print('Command sent: $cmd');
      } else {
        print('Failed to send command: $cmd');
      }
    } catch (e) {
      print('Error sending command: $e');
    }
  }
  play() async {
    for (lineByLineCmdConvertor x in items) {
      sendCommand(x.cmd);
      await Future.delayed(Duration(seconds: x.sec));
      setState(() {
        currentIndex++;
      });
    }
    _isPlay = false;
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Line by Line Cmd",
                    style: TextStyle(fontSize: 25,fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () {
                      play();
                      setState(() {
                        currentIndex = 0;
                        _isPlay = true;
                      });
                    },
                    icon: Icon(
                      Icons.play_circle,
                      size: 40,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 10,right: 10,bottom: 100),

                children: List.generate(
                  items.length,
                      (index) => Container(
                    key: ValueKey(index),
                    // Assign a unique key to each item
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.greenAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.menu),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${items[index].heading}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    if(items[index].cmd.isNotEmpty)Text("cmd : ${items[index].cmd}"),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                margin: EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${items[index].sec}s",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                )),
                            IconButton(onPressed: (){deleteItem(index);}, icon: Icon(Icons.delete,color: Colors.red,))
                            // Update text dynamically
                          ],
                        ),
                        if (currentIndex == index && _isPlay)
                          TimeProgressDemo(
                            sec: items[index].sec,
                          ),
                      ],
                    ),
                  ),
                ),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final lineByLineCmdConvertor item =
                    items.removeAt(oldIndex);
                    items.insert(newIndex, item);
                    saveItems();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: headingController,
                      decoration: InputDecoration(labelText: 'Heading'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: commandController,
                            decoration: InputDecoration(labelText: 'Command'),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: TextField(
                                controller: secondsController,
                                decoration: InputDecoration(labelText: 'Delay'),
                                keyboardType: TextInputType.number,
                              ),
                            ))
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.greenAccent),
                      ),
                      onPressed: () {
                        setState(() {
                          items.add(lineByLineCmdConvertor(
                              heading: headingController.text.trim(),
                              cmd: commandController.text,
                              sec:
                              int.tryParse(secondsController.text.trim()) ??
                                  0));
                        });
                        saveItems();
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: Text('Done'),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.add,
            size: 40,
          ),
        ),
      ),
    );
  }
}
