// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import "dart:io";

import 'dart_functions.dart';
import 'logic.dart';

import 'package:intl/intl.dart';
import "package:window_manager/window_manager.dart";

import 'package:flutter/material.dart';
import "package:file_picker/file_picker.dart";

// TODO: use the window_manager package to listen for changes on focus states of windows.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions options = const WindowOptions(
    minimumSize: Size(800, 676),
    center: true,
    title: "AppBlocker",
  );
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _dataList = []; // for the json file
  String time = DateFormat.Hms().format(DateTime.now());
  final backgroundColorGradient1 = const Color.fromRGBO(136, 148, 162, 1.0);
  final backgroundColorGradient2 = const Color.fromRGBO(188, 202, 219, 0.56);

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
  }

  void _currentTime() {
    Timer.periodic(const Duration(seconds: 1), (updatetime) {
      setState(() {
        time = DateFormat.Hms().format(DateTime.now());
      });
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
      for (var i = 0; i < _dataList.length; i++) {
        if (dupList.contains(_dataList[i])) {
          dupl = true;
          //alert the user that it already exists in the list.
          print("duplates in the list:");
          break;
        } else {
          dupList.add(_dataList[i]);
        }
      }

      if (dupl == false) {
        _dataList.add(file.name);
        writeJsonFile(_dataList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          gradient: LinearGradient(
              colors: [backgroundColorGradient1, backgroundColorGradient2]),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: const Text("Home")),
                TextButton(onPressed: () {}, child: const Text("Settings")),
                TextButton(onPressed: () {}, child: const Text("Help")),
                TextButton(onPressed: () {}, child: const Text("FAQ")),
                IconButton(onPressed: () {}, icon: const Text("DARK MODE")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 427,
                  height: 441,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(215, 218, 223, 0.76),
                    gradient: const LinearGradient(
                      colors: [Color.fromRGBO(151, 162, 170, 1), Color.fromRGBO(215, 218, 223, 0.76)]
                    ),
                    border: Border.all(
                      color: const Color.fromRGBO(9, 80, 113, 1),
                      width: 6.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 337,
                        height: 266,
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // List of programs with icons and names
                            const Expanded(
                              flex: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "RANDOM PROGRAM1",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                    )
                                  ),
                                  Text(
                                    "RANDOM PROGRAM2",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                    )
                                  ),
                                  // Todo: Constrained error; need something flexible and go to next row
                                  // Text("RANDOM PROGRAM"),
                                ]
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _pickFile();
                                  },
                                  style: const ButtonStyle(
                                    fixedSize: MaterialStatePropertyAll(Size.fromWidth(100)),
                                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                                    backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(9, 80, 113, 1)),
                                  ),
                                  child: const Text(
                                    "Add", 
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          ]
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                      // Expanded(
                      //   child: ListView.builder(
                      //     itemCount: _dataList.length,
                      //     itemBuilder: (context, index) {
                      //       return Card(
                      //           child: ListTile(
                      //         // leading:  <- have the program icon here, maybe timer as well
                      //         title: Center(child: Text(_dataList[index])),
                      //         trailing: TextButton(
                      //             onPressed: () {
                      //               //remove first from list -> update displayed list
                      //               setState(() {
                      //                 _dataList.removeAt(index);
                      //               });
                      //               // call the remove function of json file and to remove the list
                      //               removeDataJsonFile(_dataList);
                      //             },
                      //             child: const Text("Remove")),
                      //       ));
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 181,
                      height: 293,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(198, 205, 213, 1),
                        // TODO: Change left side border to null
                        border: Border.all(
                          color: const Color.fromRGBO(9, 80, 113, 1),
                          width: 6,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.all(8.0),
                            color: const Color.fromRGBO(198, 205, 213, 1),
                            child: const Text("TAB LIST"),
                          )),
                        ],
                      ),
                    ),
                    Container(
                      width: 181,
                      height: 148,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(198, 205, 213, 1),
                        // TODO: change the top and left border side to null
                        border: Border.all(
                          color: const Color.fromRGBO(9, 80, 113, 1),
                          width: 6,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Text("ICON statistics"),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
