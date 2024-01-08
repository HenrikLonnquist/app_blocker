// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import 'dart:collection';
import "dart:io";
import 'package:flutter/cupertino.dart';
import "package:image/image.dart" as img;

import 'package:app_blocker/gridview_custom.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

import "block_info.dart";
import 'dart_functions.dart';
import 'logic.dart';
import 'custom_button.dart';

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


// TODO: IMPROVEMENT?: use the window_manager package to listen for changes on focus states of windows. Together with setwinhookevent, i guess.
// TODO: FEATURE: Emergency trigger, will make you do a mission that is annoying and long.
// TODO: add the fonts folder to the assets folder.
/* 
TODO: able to make some tabs non-negtionable, meaning that the conditions and apps are permanent; Immutable.
A workaround would be to re-create it with changed values. Maybe set a condition for deleting it as well. AI? Will ask
questions about why the user want to delete it(Just an idea, but the other two seems okay). Can have user do a three day trial
and then it will be changeable again or a quick-preview with the AI and the other features(not able to change or delete 
it with condition and AI). 
Condition(s) or task(s) for deleting it: Emergency:
- Popup with questions or messages about encouraging not to delete and keep it.
-
*/

// TODO: make a loading screen... During the start of the app or loading of the contents.
// Try to open the window as fast as possible and have a loading screen. So like a delay for the contents?

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
  
  Map<int, dynamic> tempMap = {}; // from the customgridview, which are selected
  
  int currentTab = 0;
  
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

  final linkToCustomButton = LayerLink(); // dropdownbutton/custom selected
  

  Map headerButtonSelected = {"Home": true,};

  Color selectedColor = const Color.fromRGBO(217, 217, 217, 1);


  late double contextWidth = MediaQuery.of(context).size.width;

  late double contextHeight = MediaQuery.of(context).size.height;

  // TODO: Make a list of variables for colors.
  Color borderColor = const Color.fromRGBO(255, 0, 0, 1);
  
  bool activeTab = false;

  ActiveWindowManager winManager = ActiveWindowManager();

  //! Better naming please
  bool? selectState;
  
  final TextEditingController _tabTitleTextController = TextEditingController();
  
  bool isEditing = true;

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
    
    callData();
    //! maybe not do this until all is load? Faster startup?
    winManager.monitorActiveWindow();

    textController.text = dataList["tab_list"][currentTab]["options"]["time"];
    _tabTitleTextController.text = dataList["tab_list"][currentTab]["name"];

  }

  @override
  void dispose() {
    
    textController.dispose();
    removeOverlay();
    myFocusNode.dispose();
    _tabTitleTextController.dispose();

    super.dispose();
  }
  
  void callData() {
    dataList = readJsonFile();
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
            //TODO: LATER: make its own file?
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
                  //TODO: fix the spacing when resizing. Between what?
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
                        InkWell(
                          onTap: (){
                            setState(() {
                              headerButtonSelected.clear();
                              headerButtonSelected["Home"] = true;
                            });
                            // TODO: add navigation route-pop.
                            // When the layout or settings design is finished.
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
                            //TODO: DARKMODE.

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
                  // TODO: test only the program list container, because its contents wont resize with window
                  
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
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isEditing ?
                                GestureDetector(
                                  onDoubleTap: (){
                                    setState(() {
                                      isEditing = false;
                                    });
                                  },
                                  child: Text(
                                    dataList["tab_list"][currentTab]["name"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: "BerkshireSwash",
                                    ),
                                  ),
                                ) :
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _tabTitleTextController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: "BerkshireSwash"
                                    ),
                                    onTapOutside: (event){
                                      setState(() {
                                        isEditing = true;
                                      });
                                    },
                                    onSubmitted: (value){
                                      setState(() {
                                  
                                        isEditing = true;
                                  
                                        dataList["tab_list"][currentTab]["name"] = value;
                                  
                                        writeJsonFile(dataList);
                                      });
                                    },
                                    cursorColor: Colors.white,
                                    // TODO: LATER: keyboard ESC-key to exit input/textfield
                                    // TODO: BUG?: Problem with slight movement when switching between text and textfield.
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                if (isEditing)InkWell(
                                  onTap: (){
                                    setState(() {
                                      
                                      _tabTitleTextController.text = dataList["tab_list"][currentTab]["name"];
                                      isEditing = false;
                                      
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Icon(
                                      Icons.edit_square,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 130,
                                        child: ElevatedButton(
                                          onPressed: (){

                                            setState(() {
                                              if (tempMap.length == dataList["tab_list"][currentTab]["program_list"].length){
                                                selectState = false; // Deselect All
                                              } else {
                                                selectState = true; // Select All
                                              }
                                            });
                                          },
                                          // TOOD: will rename to deselect all if there is programs
                                          child: tempMap.isEmpty ? 
                                          const Text("Select All") :
                                          const Text("Deselect All"),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: contextWidth * 0.5,
                            height: contextHeight * 0.45,
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                            margin: const EdgeInsets.fromLTRB(53, 0, 53, 40),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(53, 53, 53, 1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: CustomGridView(
                                    itemCount: dataList["tab_list"][currentTab]["program_list"].length,
                                    programNames: dataList["tab_list"][currentTab]["program_list"],
                                    currentTab: currentTab,
                                    selectState: selectState,
                                    checkForAllPrograms: true,
                                    onSelectedChanged: (programNames){
                                
                                      setState(() {
                                        tempMap = programNames;
                                        selectState = null;
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
                                          onPressed: () async {
                                            
                                            Navigator.of(context).push(ActiveProgramSelection(
                                              dataList: dataList["tab_list"][currentTab]["program_list"],
                                              onSaved: (saved){

                                                for (var program in saved) {

                                                  String iconName = "i_${program["name"].split(".")[0]}.png";
                                                  File file = File("assets/program_icons/$iconName");

                                                  if (!file.existsSync()){
                                                    file.writeAsBytesSync(img.encodePng(program["icon"]));
                                                  }

                                                  if (program["name"] == "allPrograms.exe"){
                                                    
                                                    dataList["tab_list"][currentTab]["program_list"].insert(0,
                                                      {
                                                        "name": program["name"],
                                                        "icon": "assets/program_icons/i_${program["name"].split(".")[0]}.png"
                                                      }
                                                    );

                                                  } else {
                                                    
                                                    dataList["tab_list"][currentTab]["program_list"].add(
                                                      {
                                                        "name": program["name"],
                                                        "icon": "assets/program_icons/i_${program["name"].split(".")[0]}.png"
                                                      }
                                                    );

                                                  }

                                                  //TODO: Snackbar or showdialog to ask if the user wants to remove the existing program in the list?

                                                }

                                                
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
                                            
                                            // Looking for duplicates that might use the same icon == do not delete icon
                                            List tempList = []; 
                                            List duplicates = [];

                                            for (var i = 0; i < dataList["tab_list"].length; i++) {
                                              
                                              var tab = dataList["tab_list"][i];

                                              for (var j = 0; j < tab["program_list"].length; j++) {
                                                
                                                var program = tab["program_list"][j]["name"];
                                                tempList.add(program);

                                                if (tempList.contains(program)){
                                                  duplicates.add(program);
                                                }
                                              }
                                              
                                            }

                                            for(var program in tempMap.values){
                                              var index = list.indexOf(program);
                                              if (!duplicates.contains(program["name"])){
                                                File(program["icon"]).delete();
                                              }
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
                                      
                                      child: CompositedTransformTarget(
                                        link: link,
                                        child: TextFormField( 
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                          ),
                                          // onTapOutside: (event) {
                                            
                                          //   // TODO: try make it so that when it unfocus, it will the save the input.
                                          //   // Reminder to "save" or popup do you want to save the textformfield?
                                          //   var snackBar = SnackBar(
                                          //     content: const Center(
                                          //       child: Text(
                                          //         "Do you want to save the input?",
                                          //         style: TextStyle(
                                          //           color: Colors.black,
                                          //           fontWeight: FontWeight.w600,
                                          //         ),
                                          //       )
                                          //     ),
                                          //     duration: const Duration(milliseconds: 3000),
                                          //     width: 300,
                                          //     backgroundColor: Colors.white,
                                          //     behavior: SnackBarBehavior.floating,
                                          //     shape: RoundedRectangleBorder(
                                          //       borderRadius: BorderRadius.circular(10),
                                          //     ),
                                          //     action: SnackBarAction(
                                          //       label: "Save",
                                          //       onPressed: (){
                                          //         print("saved");
                                          //       },
                                          //     )
                                          //   );

                                          //   //! But this needs validation first.

                                          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                          // },
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
                                            
                                            // TODO: Probably good to make this into a function.
                                            var snackBar = SnackBar(
                                              content: const Center(
                                                child: Text(
                                                  "Saved",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              // TODO: LATER-FIX: dont like the animation when it disappears.
                                              duration: const Duration(milliseconds: 1100),
                                              width: 300,
                                              backgroundColor: Colors.white,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
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


                                            
                                            //* and the first number cannot be higher the second number; 2200-2100 <- invalid
                                            //* maybe above should work
                                            //!  0000-0615 this wont work, I think
                                            
                                            //! should be able to have more than 2 time periods, 
                                            //! ex; 0000-1200,1800-2000,2245-2359--Should work now
                                            //! 0000 & 2400 should be the same,
                                            // look up the github repo on leechblock.
                                            //! maybe I should not switch if the second number is lower


                                            // TODO: LATER: need a better solution for this, more robust and complete towards valid time
                                            // matches this: 0900-1230,1330-1700, noduplicates
                                            if (RegExp(r"^\d{4}-\d{4}(,\d{4}-\d{4})*$").hasMatch(value) && noDupl) {
                                              
                                              // Splits the value into 2 lists if there are more than 1 time periods
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
                                              
                                              // Check for valid time "numbers"
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
                                      child: CompositedTransformTarget(
                                        link: linkToCustomButton,
                                        child: CustomDropdownButton(
                                          link: linkToCustomButton,
                                          dataList: dataList["tab_list"][currentTab]["options"]["repeat"],
                                          currentTab: currentTab,
                                          onSaved: (list){

                                            //! What am I doing here?
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
                                    ),
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
                  //* tab "box"
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
                            //* TAB list
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 2.5,
                                  color: Colors.white,
                                  margin: const EdgeInsets.fromLTRB(24, 25, 48, 5),
                                ),
                                Expanded(
                                  flex: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                                      child: RawScrollbar(
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
                                              return Card(
                                                key: Key("$index"),
                                                child: ListTile(
                                                  leading: Checkbox(
                                                    value: false,
                                                    // value: dataList["tab_list"][index]["active"],
                                                    fillColor: dataList["tab_list"][index]["active"] ?
                                                    const MaterialStatePropertyAll(Colors.green) : 
                                                    const MaterialStatePropertyAll(Colors.red),
                                                    // focusColor: Colors.transparent,
                                                    // hoverColor: Colors.transparent,
                                                    side: const BorderSide(
                                                      width: 2,
                                                    ),
                                                    shape: const CircleBorder(),
                                                    onChanged: (value){
                                                                                                
                                                      //* Validate textformfield time + repeat dropdown + program list
                                                      var programList = dataList["tab_list"][index];
                                                      var options = dataList["tab_list"][index]["options"];

                                                      // TODO: maybe just check if time and dropdown is empty, just dont
                                                      // add the empty active tab to condition or "watch" list.
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

                                                        //TODO: Alert user, what exactly was not valid.
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


                                                    // TODO: check if time input is invalid, then ask if the user want
                                                    // to go back and edit/change. If no, keep the change but will 
                                                    // de-active the tab if its active. Or just message the user that the tab 
                                                    // is deactive because the time/something is invalid.
                                                    // if (textController)

                                                    setState(() {
                                                      currentTab = index;
                                                      tempMap.clear();
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
                                                    dataList["tab_list"][index]["name"],
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
                                          writeJsonFile(dataList);
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
                        //* Bottom right box
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                            child: Material(
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //* Statistics
                              
                                  // TODO: make an class or something(variable) for the elevatedbutton. If
                                  // their will be more then it will probably have the same properties
                                  // other than the icon and text name.
                                  // But probably a class, seeing as I will push a new window onto the existing
                                  // So the class will take a child widget to desgin the layout.
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      backgroundColor: const Color.fromRGBO(42, 46, 50, 1),
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    onPressed: (){
                              
                                      //TODO: new page? statistics
                                      
                                    },
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //TODO: switch to figma icon(download and create icon folder in assets)
                                        Icon(
                                          Icons.data_thresholding_rounded,
                                          size: 55,
                                          color: Color.fromRGBO(253, 65, 60, 1),
                                        ),
                                        Text(
                                          "Statistics",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //* File picker button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      backgroundColor: const Color.fromRGBO(42, 46, 50, 1),
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    onPressed: (){
                              
                                      //TODO: add file_picker or write my own to the winapi
                                      //How would I write my own to do that?
                                      //look up the file picker github
                                      //
                                      
                                    },
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //TODO: switch to figma icon(download and create icon folder in assets)
                                        Icon(
                                          Icons.drive_file_move_rtl,
                                          size: 55,
                                          color: Color.fromRGBO(253, 65, 60, 1),
                                        ),
                                        Text(
                                          "File Picker",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //* Block info button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // splashFactory: NoSplash.splashFactory,
                                      foregroundColor: Colors.red,
                                      backgroundColor: const Color.fromRGBO(42, 46, 50, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    onPressed: (){
                                      print("hello");
                                      // TODO: Show list of currently blocking(database/storage/dataList)
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context){
                                            return const BlockInfo();
                                          },
                                        )
                                      );
                                      
                                    },
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //TODO: switch to figma icon(download and create icon folder in assets)
                                        Icon(
                                          Icons.block_sharp,
                                          size: 55,
                                          color: Color.fromRGBO(253, 65, 60, 1),
                                        ),
                                        Text(
                                          "Block info",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
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
