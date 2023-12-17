// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import 'dart:collection';
import "dart:io";
import 'dart:ui';

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

/*
Different sections:
- "HEADER"
- Program List
- Tab List
- Option block
  - TextFieldForm
  - Repeat option

 */


// TODO: use the window_manager package to listen for changes on focus states of windows.
// TODO: Emergency trigger, will make you do a mission that is annoying and long.
/* 
TODO: able to make some tabs non-negtionable, meaning that the conditions and apps are permanent; Not changeable.
A workaround would be to re-create it with changed values. Maybe set a condition for deleting it as well. AI? Will ask
questions about why the user want to delete it(Just an idea, but the other two seems okay). Can have user do a three day trial
and then it will be changeable again or a quick-preview with the AI and the other features(not able to change or delete 
it with condition and AI). 
Condition(s) or task(s) for deleting it: Emergency:
- Popup with questions or messages about encouraging not to delete and keep it.
-
*/

//TODO: make a loading screen...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions options = const WindowOptions(
    minimumSize: Size(953, 709),
    // size: Size(953, 709),
    // center: true,
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
  int currentTab = 2;
  Map<String, dynamic> dummyMap = {};
  final ScrollController _scrollController = ScrollController();
  String time = DateFormat("HHmm").format(DateTime.now());
  final backgroundColorGradient1 = const Color.fromRGBO(136, 148, 162, 1.0);
  final backgroundColorGradient2 = const Color.fromRGBO(188, 202, 219, 0.56);
  TextEditingController textController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();
  bool validationError = false;
  

  OverlayEntry? overlayEntry;
  final link = LayerLink(); // tooltip textformfield
  final link2 = LayerLink(); // dropdownbutton/custom selected
  
  Map headerButtonSelected = {"Home": true,};
  Color selectedColor = const Color.fromRGBO(217, 217, 217, 1);

  late double contextWidth = MediaQuery.of(context).size.width;
  late double contextHeight = MediaQuery.of(context).size.height;

  // TODO: Make a list of variables for colors.
  Color borderColor = const Color.fromRGBO(255, 0, 0, 1);
  
  bool activeTab = false;
  ActiveWindowManager winManager = ActiveWindowManager();

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
    //! What do I need this for?
    //! maybe for the current time left or something similar
    // _currentTime(); 
    callData();
    //! maybe not do this until all is load?
    winManager.monitorActiveWindow();

    textController.text = dataList["tab_list"][currentTab]["options"]["time"];

  }

  @override
  void dispose() {
    textController.dispose();
    removeOverlay();
    myFocusNode.dispose();

    super.dispose();
  }
  
  //TODO: probably just move this to the initstate directly, no need for a method?
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color.fromRGBO(33, 37, 41, 1),
        child: Column(
          children: [
            const SizedBox(height: 20),
            //! "HEADER"
            //TODO: make its own file?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.68,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(49, 56, 64, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )
                  ),
                  //TODO: fix the spacing when resizing
                  //TODO: make this into a class and it's file
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        const SizedBox(width: 20.0),
                        const Icon(
                          Icons.cabin,
                          color: Colors.white,
                        ),
                        const Spacer(flex:1),
                        //TODO: animation to shift the selected color to the pressed text/button
                        // probably need to do a funciton and gesturedectection or inkwell on all the texts.
                        InkWell(
                          onTap: (){
                            setState(() {
                              headerButtonSelected.clear();
                              headerButtonSelected["Home"] = true;
                            });
                            //TODO: add navigation route-pop.
                          },
                          splashColor: Colors.transparent,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          highlightColor: Colors.transparent,
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              color: headerButtonSelected["Home"] != null ? const Color.fromRGBO(71, 71, 71, 1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Home",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: headerButtonSelected["Home"] != null ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex:2),
                        InkWell(
                          onTap: (){
                            setState(() {
                              headerButtonSelected.clear();
                              headerButtonSelected["Settings"] = true;
                            });
                            //TODO: add navigation route-pop.
                          },
                          splashColor: Colors.transparent,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          highlightColor: Colors.transparent,
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              color: headerButtonSelected["Settings"] != null ? const Color.fromRGBO(71, 71, 71, 1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: headerButtonSelected["Settings"] != null ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex:2),
                        InkWell(
                          onTap: (){
                            setState(() {
                              headerButtonSelected.clear();
                              headerButtonSelected["Help"] = true;
                              //TODO: add navigation route-pop.
                            });
                          },
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              color: headerButtonSelected["Help"] != null ? const Color.fromRGBO(71, 71, 71, 1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Help",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: headerButtonSelected["Help"] != null ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex:2),
                        InkWell(
                          onTap: (){
                            //TODO:

                          },
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            //TODO: only need to change the color of this
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        const Spacer(flex:1),
                      ],
                    ),
                  )
                ),
                Container(
                  height: 50,
                  width: 150,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(172, 172, 172, 1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "John Doe",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "BerkshireSwash",
                              ),
                            ),
                            Text(
                              "JohnDoe@email.com",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: "BerkshireSwash",
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (){},
                            customBorder: const CircleBorder(),
                            // splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: const Icon(
                              Icons.account_circle,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Row(
                children: [
                  //* Program List
                  // TODO: test with only program list box to, because its contents wont resize with window
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(42, 46, 50, 1),
                        border: Border.all(
                          color: borderColor,
                          width: 6.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      //TODO: maybe wrap this inside a container, it's contents wont resize with the parent container(above)
                      child: Column(
                        children: [
                          Container(
                            width: contextWidth * 0.5,
                            height: contextHeight * 0.45,
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                            margin: const EdgeInsets.fromLTRB(53, 44, 53, 40),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(53, 53, 53, 1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                                    onSelectedChanged: (programNames){
                                
                                      setState(() {
                                        tempMap = programNames;
                                      });
                                
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
                                            // _pickFile();
                                            
                                            //call the class for activeProgramselection
                                            Navigator.of(context).push(ActiveProgramSelection(
                                              dataList: dataList["tab_list"][currentTab]["program_list"],
                                              onSaved: (saved){

                                                for (var program in saved){
                                                  dataList["tab_list"][currentTab]["program_list"].add(program);
                                                }

                                                print(dataList["tab_list"][currentTab]["program_list"]);
                                                setState(() {
                                                  writeJsonFile(dataList);
                                                });

                                              },
                                            ));


                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                                          ),
                                          child: const Text(
                                            "Add",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // if a program is selected
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: tempMap.isNotEmpty ? () {
                                            var list = dataList["tab_list"][currentTab]["program_list"];
                                
                                            for(var program in tempMap.values){
                                              var index = list.indexOf(program);
                                              list.removeAt(index);
                                            }
                                            
                                            tempMap.clear();
                                
                                            dataList["tab_list"][currentTab]["program_list"] = list;
                                            setState(() {  
                                              writeJsonFile(dataList);
                                              winManager.cancelTimer();
                                              winManager.monitorActiveWindow();
                                            });
                                          } : null,
                                          style: TextButton.styleFrom(
                                            backgroundColor: tempMap.isNotEmpty ?
                                            const Color.fromRGBO(255, 255, 255, 1) :
                                            const Color.fromRGBO(255, 255, 255, 0.5),
                                          ),
                                          child: const Text(
                                            "Remove",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]
                            ),
                          ),
                          //* Options
                          Column(
                            children: [
                              //* TextFieldForm
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(53, 0, 53, 10),
                                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                      decoration: BoxDecoration(
                                        
                                        color: const Color.fromRGBO(237, 237, 237, 1),
                                        border: validationError ? Border.all(
                                          color: Colors.red
                                        ) : null,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      //TODO: try make it so that when it unfocus, it will the save the input
                                      child: CompositedTransformTarget(
                                        link: link,
                                        child: TextFormField( 
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                          focusNode: myFocusNode,
                                          controller: textController,
                                          keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true,
                                            signed: true,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r"^[\d\-,]{0,}")),
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


                                            // matches this: 0900-1230,1330-1700, noduplicates
                                            //* and the first number cannot be higher the second number; 2200-2100 <- invalid
                                            
                                            //! should be able to have more than 2 time periods, ex; 0000-1200,1800-2000,2245-2359--Should work now
                                            if (RegExp(r"^\d{4}-\d{4}(,\d{4}-\d{4})*$").hasMatch(value) && noDupl) {
                                              
                                              var temp = value.split(RegExp(r"[\,]+"));
                                              var sortTemp = [];
                                              for (var time in temp){

                                                var splitTime = time.split("-")..sort((a, b) {

                                                  var intA = int.parse(a);
                                                  var intB = int.parse(b);
                                                  return intA.compareTo(intB);

                                                });
                                                sortTemp.add(splitTime);

                                              }
                                              value = [ for(var item in sortTemp) "${item[0]}-${item[1]}" ].join(",");
                                              
                                              // Check for valid time
                                              for (var time in temp){

                                                var hour = int.parse(time.substring(0, 2));
                                                var min = int.parse(time.substring(2, 4));

                                                if ( hour > 24|| min >= 60){

                                                  myFocusNode.requestFocus();
                                                  validationError = true;
                                                  print("validation error");
                                                  showOverlayTooltip();
                                                  return;

                                                }
                                              }
                                              
                                              validationError = false;

                                              removeOverlay();
                                  
                                              dataList["tab_list"][currentTab]["options"]["time"] = value;
                                              setState(() {
                                                writeJsonFile(dataList);
                                                textController.text = value;
                                              });
                                              
                                              //Updating the monitor dataList
                                              winManager.cancelTimer();
                                              winManager.monitorActiveWindow();

                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              
                                            } else {
                                              validationError = true;
                                              myFocusNode.requestFocus();
                                              
                                              showOverlayTooltip();
                                            }
                                        
                                          },
                                          cursorHeight: 24,
                                          decoration: InputDecoration(
                                            focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
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
                              //* Repeat option
                              Padding(
                                padding: const EdgeInsets.fromLTRB(53, 10, 53, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      //TODO: come up with a better name for it
                                      child: CompositedTransformTarget(
                                        link: link2,
                                        child: CustomOverlayPortal(
                                          link: link2,
                                          dataList: dataList["tab_list"][currentTab]["options"]["repeat"],
                                          currentTab: currentTab,
                                          onSaved: (list){
                                                                      
                                            if(list.length > 3){
                                              var sortedKeys = list[3].keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                                              var sortedMap = {for (var key in sortedKeys) key:list[3][key]};
                                              list[3] = sortedMap;
                                            }
                                            
                                            dataList["tab_list"][currentTab]["options"]["repeat"] = list;
                                            setState(() {
                                              writeJsonFile(dataList);
                                              winManager.cancelTimer();
                                              winManager.monitorActiveWindow();
                                            });
                                            
                                          }
                                        ),
                                      )
                                      //TODO: something else here as well
                                    ),
                                    //TODO: add a button for removing current repeat info/chosen options
                                    // to default "Repeat"/Null
                                    //! probably better to have it inside the customoverlayrepeat file

                                    Expanded(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.white,
                                      )
                                    )
                                  ],
                                ),
                              )
                            ]
                          ),
                        ],
                      ),
                    ),
                  ),
                  //* tab list
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(42, 46, 50, 1),
                              border: Border(
                                left: BorderSide.none,
                                
                                top: BorderSide(
                                  color: borderColor,
                                  width: 6,
                                ),
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 6,
                                ),
                                right: BorderSide(
                                  color: borderColor,
                                  width: 6,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.zero,
                                topRight: Radius.circular(15.0),
                                topLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              )
                            ),
                            // TODO: make it shift to left and back original position; just change the padding.
                            // all depending on the scrollbar is showing or not.
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 2.5,
                                  color: Colors.white,
                                  //TODO: change right margin when scrollbar is showing; 48 to 24
                                  margin: const EdgeInsets.fromLTRB(24, 25, 48, 5),
                                ),
                                Expanded(
                                  flex: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      child: RawScrollbar(
                                        //TODO: Scroller needs padding, too close to the wall on the rightside of it
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        thickness: 10,
                                        thumbColor: Colors.deepPurple,
                                        trackVisibility: false,
                                        thumbVisibility: true,
                                        controller: _scrollController,
                                        child: Material(
                                          color: Colors.transparent,
                                          // color: const Color.fromRGBO(217, 217, 217, 1),
                                          child: ReorderableListView.builder(
                                            buildDefaultDragHandles: false,
                                            padding: const EdgeInsets.fromLTRB(26, 3, 30, 8),
                                            scrollController: _scrollController,
                                            onReorder: (oldIndex, newIndex) {
                                              if (oldIndex < newIndex){
                                                newIndex -= 1;
                                              }
                                              final Map item = dataList["tab_list"].removeAt(oldIndex);
                                              dataList["tab_list"].insert(newIndex, item);
                                              currentTab = newIndex;
                                          
                                            },
                                            itemCount: dataList["tab_list"].length,
                                            itemBuilder: (context, index) {
                                              //TODO: need to remove background color when dragging.
                                              return Card(
                                                key: Key("$index"),
                                                child: ListTile(
                                                  //TODO: change switch widget to something else, too big
                                                  leading: Switch(
                                                    value: dataList["tab_list"][index]["active"],
                                                    splashRadius: 0.0,
                                                    focusColor: Colors.transparent,
                                                    hoverColor: Colors.transparent,
                                                    onChanged: (value){
                                                                                                
                                                                                                
                                                      //TODO: validation for all the blocking options;
                                                      //* textformfield time + repeat dropdown
                                                      var programList = dataList["tab_list"][index];
                                                      var options = dataList["tab_list"][index]["options"];
                                                                                                
                                                      if (textController.text.isNotEmpty 
                                                      && programList["program_list"].isNotEmpty 
                                                      && options["repeat"].isNotEmpty
                                                      && options["time"] != null ){
                                                                                                
                                                        dataList["tab_list"][index]["active"] = value;
                                                        print("Valid");
                                                        setState(() {
                                                          writeJsonFile(dataList);
                                                          winManager.cancelTimer();
                                                          winManager.monitorActiveWindow();
                                                        });
                                                      } else {
                                                                                                
                                                        print("Not valid");
                                                        //Snackbar? 
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                          action: SnackBarAction(
                                                            textColor: Colors.black,
                                                            label: "label",
                                                            onPressed: () {
                                                              
                                                            },
                                                          ),
                                                          content: const Center(
                                                            child: Text(
                                                              "Missing inputs",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w600,
                                                              )
                                                            )
                                                          ),
                                                          duration: const Duration(seconds: 5),
                                                          width: 300,
                                                          backgroundColor: Colors.white,
                                                          behavior: SnackBarBehavior.floating,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ));
                                                                                                
                                                      }
                                                    },
                                                  ),
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
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "BerkshireSwash",
                                                    )
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        hoverColor: Colors.transparent,
                                                        onPressed: (){
                                                          setState(() {
                                                            dataList["tab_list"].removeAt(index);
                                                            writeJsonFile(dataList);
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.remove_circle_outlined,
                                                          // size: 20,
                                                        ),
                                                      ),
                                                      ReorderableDragStartListener(
                                                        index: index,
                                                        child: const Icon(
                                                          Icons.drag_handle,
                                                          // size: 20,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                      ),
                                    ) 
                                ),
                                Container(
                                  height: 2.5,
                                  color: Colors.white,
                                  margin: const EdgeInsets.fromLTRB(24, 5, 48, 0),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 12, 30, 12),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)
                                        )
                                      ),
                                      onPressed: () {
                                        
                                        /*
                                        dat structure: 
                                        #DAILY
                                        time is required or it wont block
                                        active: false,
                                        repeat: [
                                          "Daily" - everyday at 2300-2400
                                        ],
                                        time: "2300-2400"
                                        */
                                        
                                        /*
                                        (?) == maybe
                                        TODO: able to name the tab; 
                                        * default value: tab + number
                                        * request focus when textfield created
                                        * ?double tap on text to rename
                                        * ?remove textfield on submit and replace it with the listtile
                                        */
                                        
                                        dummyMap = {
                                          "name": "Tab ${dataList["tab_list"].length + 1}",
                                          "active": false,
                                          "program_list": [],
                                          "options": {
                                            "repeat": [],
                                            "time": "",
                                          }
                                        }; 
                                        dataList["tab_list"].add(dummyMap);
                                        setState(() {
                                          // writeJsonFile(dataList);
                                        });

                                      },
                                      child: const Text(
                                        "ADD",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          fontFamily: "KeaniaOne",
                                        ),
                                      ),
                                    ),
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        //* Statistics
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(42, 46, 50, 1),
                              border:  Border(
                                left: BorderSide.none,
                                top: BorderSide.none,
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 6,
                                ),
                                right: BorderSide(
                                  color: borderColor,
                                  width: 6,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.zero,
                                topRight: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              ),
                            ),
                            child: Center(
                              //TODO: want box shape, instead of a circle
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.all(0),
                                  hoverColor: Colors.grey.shade800,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: (){},
                                //TODO: switch to figma icon(download and create icon folder in assets)
                                icon: const Icon(
                                  Icons.data_thresholding_rounded,
                                  size: 60,
                                  color: Color.fromRGBO(253, 65, 60, 1),
                                ),
                              ),
                            )
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

}
