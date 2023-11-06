// ignore_for_file: avoid_print

import 'dart:async';

import 'package:app_blocker/dart_functions.dart';
import 'package:app_blocker/logic.dart';
import 'package:intl/intl.dart';

// import "logic.dart";

import 'package:flutter/material.dart';
import "package:file_picker/file_picker.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // data handle
  // List _dataList = []; // for displaying to listview
  List _dataList = []; // for the json file
  var dataPath = "assets/data.json";
  
  // time
  int timeLeft = 5;
  String time = DateFormat.Hms().format(DateTime.now());
  

  @override
  void initState() {
    super.initState();
    _currentTime();
    
    callData();
    
    monitorActiveWindow();

  }

  // calling data and adding to list widget to display in list view
  void callData() {

    _dataList = readJsonFile();
    // for (var i = 0; i < _dataList.length; i++) {
    //   _dataList.add(Text(_dataList[i]));
    // }    

  }

  void _currentTime() {
    Timer.periodic(const Duration(seconds: 1), (updatetime) {
      setState(() {
        time = DateFormat.Hms().format(DateTime.now());
      });
    });
  }

  // timer method
  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["exe"],
      initialDirectory: "Desktop" // TODO: change back to C:
    );

    if (result == null) return;

    PlatformFile file = result.files.single;
    setState(() {
    
      // Will check for duplicates and then alert the user if there are.
      final List dupList = [];
      bool dupl = false;
      for(var i = 0; i < _dataList.length; i++) {
        if (dupList.contains(_dataList[i])) {
          dupl = true;
          //alert the user that it already exists in the list.
          print("duplates in the list:");
          break;
        } else {
          dupList.add(_dataList[i]);
        }
      }

      if ( dupl == false) {
        _dataList.add(file.name);
        writeJsonFile(_dataList);
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    // leading:  <- have the program icon here
                    title: Center(child: Text(_dataList[index])),
                    trailing: TextButton(onPressed: () {
                        //remove first from list -> update displayed list
                        setState(() {
                          
                          _dataList.removeAt(index);
                          
                          
                        });
                        // call the remove function of json file and to remove the list
                        removeDataJsonFile(_dataList);

                      }, child: const Text("Remove")
                  ),


                  )
                );
              },
            ),
          ),
          Text(
            timeLeft == 0 ? "DONE" : timeLeft.toString(),
            style: const TextStyle(fontSize: 50),
          ),
          MaterialButton(
            onPressed: _startCountdown,
            color: Colors.amberAccent[100],
            child: const Text("START"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickFile();
        },
        tooltip: 'Add program',
        child: const Icon(Icons.add),
      ),
    );
  }
}
