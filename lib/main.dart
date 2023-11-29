// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import "dart:io";

import 'package:flutter/services.dart';

import 'dart_functions.dart';
import 'logic.dart';
import "custom_overlay_repeat.dart";

import 'package:intl/intl.dart';
import "package:window_manager/window_manager.dart";

import 'package:flutter/material.dart';
import "package:file_picker/file_picker.dart";

import "package:dropdown_button2/dropdown_button2.dart";

// TODO: use the window_manager package to listen for changes on focus states of windows.
/*
Different sections:
- Program List
- Tab List
- Option block
  - TextFieldForm
  - Repeat option

 */



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
  Map _dataList = {}; // for the json file
  final ScrollController _scrollController = ScrollController();
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

    // TODO: need to check if the dialog is open and then return null
    // just hade the dialog open repeatedly after clicking many times on it.
    // Maybe I could set a disable timer  after clicking it once but then it needs to show that it's loading the dialog.
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
        _dataList["program_list"].add(file.name);
        writeJsonFile(_dataList);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
            const SizedBox(height: 40),
            Wrap(
              spacing: 60.0,
              // TODO: add a widget for these instead DRY with properties when needed to change values.
              children: [
                TextButton(
                    onPressed: () {},
                    style: const ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(Size.fromWidth(77)),
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(235, 235, 235, 1)),
                    ),
                    child: const Text(
                      "Home",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )),
                TextButton(
                    onPressed: () {},
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(235, 235, 235, 1)),
                    ),
                    child: const Text(
                      "Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )),
                TextButton(
                    onPressed: () {},
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(235, 235, 235, 1)),
                    ),
                    child: const Text(
                      "Help",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    )),
                TextButton(
                    onPressed: () {},
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(235, 235, 235, 1)),
                    ),
                    child: const Text(
                      "FAQ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    iconSize: 20,
                    // TODO: add a switch towards different themes and switch the icons as well.
                    // https://stackoverflow.com/questions/62942430/flutter-change-dark-mode-switch-to-an-icon
                    icon: const Icon(
                      Icons.wb_sunny,
                    ),
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(235, 235, 235, 1)),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 427,
                  height: 441,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(215, 218, 223, 0.76),
                    gradient: const LinearGradient(colors: [
                      Color.fromRGBO(151, 162, 170, 1),
                      Color.fromRGBO(215, 218, 223, 0.76)
                    ]),
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
                        padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        //* Program List
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //TODO: Show the programs with icons and names
                              const Expanded(
                                flex: 8,
                                child: Wrap(
                                    runSpacing: 5.0, // Verttical
                                    spacing: 5.0, // Horizontal
                                    children: [
                                      // TODO: make them selectable
                                      Text("PROGRAM1",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          )),
                                      Text("PROGRAM2",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          )),
                                      // TODO: Constrained error; need something flexible and go to next row
                                      Text("PROGRAM3",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                          )),
                                    ]),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _pickFile();
                                    },
                                    style: const ButtonStyle(
                                      foregroundColor: MaterialStatePropertyAll(
                                          Colors.white),
                                      backgroundColor: MaterialStatePropertyAll(
                                          Color.fromRGBO(9, 80, 113, 1)
                                      ),
                                    ),
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                      ),
                      // Option block
                      Row(
                        children: [
                          // Repeat option
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(40, 5, 10, 0),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  CustomOverlayPortal(),
                                ]
                              ),
                            ),
                          ),
                          // TextFieldForm
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        constraints: BoxConstraints(
                                          maxHeight: 30,
                                        ),
                                        hintText: "0000-2359",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: TextFormField(
                                      onChanged: (String? value) {

                                      },
                                      validator: (String? value) {
                                        return value != null && value.contains(RegExp(r"^A-Za-z")) ? "Only numbers are allowed" : null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        constraints: BoxConstraints(
                                          maxHeight: 30,
                                        ),
                                        hintText: "0000-2359",
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                          )
                      ])  ,
                      // Text(
                      //   time,
                      //   style: const TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 30,
                      //   ),
                      // ),
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
                      //                 _dataList["program_list"].removeAt(index);
                      //               });
                      //               // overwriting existing with the new one
                      //               (_dataList);
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
                      
                      //* Tab List
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 8,
                              child: Container(
                                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: const Color.fromRGBO(217, 217, 217, 1),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey.withOpacity(0.5),
                                    //     blurRadius: 7,
                                    //     spreadRadius: 5,
                                    //     offset: const Offset(0, 4),
                                    //   ),
                                    // ]
                                  ),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: _dataList["tab_list"].length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
                                          child: TextButton(
                                            onPressed: () {
                                              //Grab info from data jsonfile and change info
                                              
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: const Color.fromRGBO(245, 245, 245, 1)
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 7,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                    child: Text(
                                                      _dataList["tab_list"][index],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      )),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: IconButton(
                                                    onPressed: (){
                                                      setState(() {
                                                        _dataList["tab_list"].removeAt(index);
                                                        writeJsonFile(_dataList);
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.remove_circle_outlined,
                                                      size: 20,
                                                    ),
                                                  ),
                                                )
                                                  
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  )
                              ) 
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: setstate will add a textbutton to tab list
                                  setState(() {
                                    _dataList["tab_list"].add("TAB ${_dataList["tab_list"].length + 1}");
                                    writeJsonFile(_dataList);
                                  });
                                  
                                },
                                child: const Text("Add TAB"),
                              ),
                            )
                          )
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
                      child: Center(
                        child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {},
                            child: const Icon(
                              Icons.data_thresholding_rounded,
                              size: 80,
                              color: Color.fromRGBO(9, 80, 113, 1),
                            )),
                      ),
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
