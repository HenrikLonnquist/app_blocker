// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import 'dart:collection';
import "dart:io";

import 'package:app_blocker/gridview_custom.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

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
- "HEADER"
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
  Map dataList = {}; // for the json file
  Map<int, String> tempMap = {}; // from the customgridview, which are selected
  int currentTab = 0;
  Map<String, dynamic> dummyMap = {};
  final ScrollController _scrollController = ScrollController();
  String time = DateFormat("HHmm").format(DateTime.now());
  final backgroundColorGradient1 = const Color.fromRGBO(136, 148, 162, 1.0);
  final backgroundColorGradient2 = const Color.fromRGBO(188, 202, 219, 0.56);
  TextEditingController textController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  bool validationError = false;
  
  Map<int, OverlayEntry> tempOverlayEntries = {};

  OverlayEntry? overlayEntry;
  final link = LayerLink();



  void showOverlayTooltip(){

    removeOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.topLeft,
          child: Align(
            alignment: const Alignment(-1.010,-0.85),
            child: GestureDetector(
              onTap: (){
                removeOverlay();
              },
              child: Material(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                child: Container(
                  width: 200,
                  height: 50,
                  padding: const EdgeInsets.all(5.0),
                  child: const Center(
                    child: Text(
                      "Ex. 0900-1230,1330-1700 press enter to save",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
    
    Overlay.of(context).insert(overlayEntry!);

  }

 

  void removeOverlay(){
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
    
  }


  @override
  void initState() {
    super.initState();
    _currentTime(); //! What do I need this for?
    callData();
    monitorActiveWindow();

    textController.text = dataList["tab_list"][currentTab]["options"]["time"];

  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    removeOverlay();

  }
  
  void callData() {
    dataList = readJsonFile();
  }

  void _currentTime() {
    Timer.periodic(const Duration(seconds: 1), (updatetime) {
      setState(() {
        time = DateFormat("HHmm").format(DateTime.now());
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
      for (var i = 0; i < dataList.length; i++) {
        if (dupList.contains(dataList[i])) {
          dupl = true;
          //alert the user that it already exists in the list.
          print("duplates in the list:");
          break;
        } else {
          dupList.add(dataList[i]);
        }
      }

      if (dupl == false) {
        dataList["tab_list"]["$currentTab"]["program_list"].add(file.name);
        writeJsonFile(dataList);
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
            const SizedBox(height: 40),
            // !"HEADER"
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
                              Expanded(
                                flex: 8,
                                
                                //TODO:  I guess another overlay is incoming or maybe a popupmenu
                                child: CustomGridView(
                                  itemCount: dataList["tab_list"][currentTab]["program_list"].length,
                                  programNames: dataList["tab_list"][currentTab]["program_list"],
                                  onSelectedChanged: (programNames, overlayEntries){

                                    tempOverlayEntries = overlayEntries;
                                    tempMap = programNames;
                                    
                                  }
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _pickFile();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromRGBO(9, 80, 113, 1)
                                        ),
                                        child: const Text(
                                          "Add",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    // if a program is selected
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          var list = dataList["tab_list"][currentTab]["program_list"];

                                          for(var program in tempMap.values){
                                            var index = list.indexOf(program);
                                            
                                            list.removeAt(index);
                                          }
                                          tempMap.clear();


                                          for (var entry in tempOverlayEntries.values) {
                                            entry.remove();
                                            entry.dispose();
                                          }
                                          tempOverlayEntries.clear();
                                          
                                          dataList["tab_list"][currentTab]["program_list"] = list;
                                          setState(() {  
                                            writeJsonFile(dataList);
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromRGBO(9, 80, 113, 1),
                                        ),
                                        child: const Text(
                                          "Remove",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]),
                      ),
                      // Option block
                      Column(
                        children: [
                          // TextFieldForm
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                  decoration: BoxDecoration(
                                    
                                    color: Colors.white,
                                    border: validationError ? Border.all(
                                      color: Colors.red
                                    ) : null,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  //TODO: try make it so that when it unfocus, it will the save the input
                                  child: CompositedTransformTarget(
                                    link: link,
                                    child: TextFormField( 
                                      focusNode: myFocusNode,
                                      controller: textController,
                                      keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true,
                                        signed: true,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r"^[\d\-,]{0,19}")),
                                      ],
                                      onFieldSubmitted: (String value){
                                        
                                        const snackBar = SnackBar(
                                          content: Text("Saved"),
                                          duration: Duration(milliseconds: 1100),
                                        );
                                    
                                        var sameNum = value.split(RegExp(r"\W+"));
                                        var uniq = [];
                                        bool noDupl = true;
                                        for(var i in sameNum) {
                                          if(uniq.contains(i)) {
                                            noDupl = false;
                                          } else {
                                            uniq.add(i);
                                          }
                                        }
                                    
                                        // match this: 0900-1230,1330-1700, noduplicates
                                        if (value.contains(RegExp(r"^\d{4}-\d{4}(?:,\d{4}-\d{4})?$")) && noDupl) {
                                          validationError = false;

                                          dataList["tab_list"][currentTab]["options"]["time"] = value;
                                          writeJsonFile(dataList);

                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                          removeOverlay();
                                            
                                          
                                        } else {
                                          validationError = true;
                                          myFocusNode.requestFocus();
                                          
                                          showOverlayTooltip();
                                        }
                                    
                                      },
                                      cursorHeight: 24,
                                      decoration: InputDecoration(
                                        suffixIcon: validationError ? const Icon(
                                          Icons.emergency,
                                          size: 16,
                                        ) : null,
                                        errorText: validationError ? "" : null,
                                        errorStyle: const TextStyle(height: 0),
                                        hintText: "Ex. 0900-1230,1330-1700",
                                        constraints: const BoxConstraints(
                                          maxHeight: 30,
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          // Repeat option
                          Padding(
                            padding: const EdgeInsets.fromLTRB(40, 0, 40, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: CustomOverlayPortal(
                                    dataList: dataList,
                                    currentTab: currentTab,
                                  )
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    // height: MediaQuery.of(context).size.height,
                                    height: 48,
                                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(9, 80, 113, 1),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "temporary", // TODO: change to a variable later(Changes from CustomOverlayPortal)
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ]
                      ),
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
                                  child: RawScrollbar(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    thickness: 10,
                                    thumbColor: Colors.deepPurple,
                                    trackVisibility: false,
                                    thumbVisibility: true,
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: dataList["tab_list"].length,
                                      itemBuilder: (context, index) {
                                        return Material(
                                          color: const Color.fromRGBO(217, 217, 217, 1),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8, 0, 14, 8),
                                            child: ListTile(
                                              onTap: () {
                                                setState(() {
                                                  currentTab = index;
                                                  textController.text = dataList["tab_list"][currentTab]["options"]["time"];
                                                  validationError = false;
                                                  removeOverlay();
                                                });
                                              },
                                              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              textColor: Colors.deepPurple,
                                              iconColor: Colors.deepPurple,
                                              tileColor: currentTab == index ?
                                               const Color.fromRGBO(245, 113, 161, 1.0) :
                                               const Color.fromRGBO(245, 245, 245, 1.0),
                                              title: Text(
                                                "${dataList["tab_list"][index]["name"]}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "BerkshireSwash",
                                                )
                                              ),
                                              trailing: IconButton(
                                                onPressed: (){
                                                  setState(() {
                                                    dataList["tab_list"].removeAt(index);
                                                    writeJsonFile(dataList);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle_outlined,
                                                  size: 20,
                                                ),
                                              ),
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                  )
                                ),
                                onPressed: () {
                                  String hourMin = DateFormat("HH:mm").format(DateTime.now());
                                  String weekday = DateFormat("E").format(DateTime.now());
                                  String month = DateFormat("d/M").format(DateTime.now());
                                  String year = DateFormat("d/M/y").format(DateTime.now());
                                  print(hourMin);
                                  print(weekday);
                                  print(month);
                                  print(year);
                                  setState(() {
                              
                                    
                              
                                    dummyMap = {
                                      "name": "Tab ${dataList["tab_list"].length + 1}",
                                      "program_list": [],
                                      "options": {
                                        "repeat": [],
                                        "time": "",
                                      }
                                    }; 
                                    dataList["tab_list"].add(dummyMap);
                                    
                                    writeJsonFile(dataList);
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
