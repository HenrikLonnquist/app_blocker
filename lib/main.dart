// ignore_for_file: avoid_print, unused_import, unused_local_variable

import 'dart:async';
import 'dart:collection';
import "dart:io";
import "dart:ui" as ui;
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

// TODO: Feedback/Report option: Can't find your program? Just write the name of the program.
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
    minimumSize: Size(998, 646),
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
      debugShowCheckedModeBanner: false,
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  
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

  
  ActiveWindowManager winManager = ActiveWindowManager();

  //! Better naming please
  bool? selectState;
  
  final TextEditingController _tabTitleTextController = TextEditingController();
  
  bool isEditing = true;
  
  // TODO: Make a list of variables for colors.
  Color borderColor = const Color.fromRGBO(255, 0, 0, 1);
  Color boxInnerColor = const Color.fromRGBO(42, 46, 50, 100);
  Color backgroundColor = const Color.fromRGBO(33, 37, 41, 100);
  
  bool isChecked = false;
  List daysOftheWeek = [
    "Mon",
    "Tue",
    "Wed",
    "Thur",
    "Fri",
    "Sat",
    "Sun"
  ];
  
  late TabController _optionsTabController;
  
  
  
  

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
    _optionsTabController = TabController(length: 2, vsync: this);

  }

  @override
  void dispose() {
    
    textController.dispose();
    removeOverlay();
    myFocusNode.dispose();
    _tabTitleTextController.dispose();
    _optionsTabController.dispose();

    super.dispose();
  }
  
  void callData() {
    dataList = readJsonFile();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(33, 37, 41, 1),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            //* Left BOX
            // TODO: test only the program list container, because its contents wont resize with window
            Expanded(
              flex: 7,
              child: Container(
                color: backgroundColor,
                padding: const EdgeInsets.fromLTRB(37, 30, 37, 45),
                child: Column(
                  children: [
                    //! "HEADER"
                    //TODO: LATER: make its own class and file?
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //* LOGO
                        // TODO: if failed to find image create an widget icon.
                        Image.file(File("assets/temp_logo.png")),
                        const Spacer(flex: 2),
                        //* HOME
                        // TODO: make it into it's own class
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Home",
                                style: TextStyle(
                                  fontWeight: headerButtonSelected["Home"] != null ? FontWeight.w600 : FontWeight.normal,
                                  fontFamily: "BerkshireSwash",
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red,
                                  decorationThickness: headerButtonSelected["Home"] != null ?  2.0 : 0,
                                  shadows: [
                                    Shadow(
                                      color: headerButtonSelected["Home"] != null ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.7),
                                      offset: const Offset(0, -8),
                                    )
                                  ],
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        //* Settings
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
                              
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  fontWeight: headerButtonSelected["Settings"] != null ? FontWeight.w600 : FontWeight.normal,
                                  fontFamily: "BerkshireSwash",
                                  fontSize: 18,
                                  color: headerButtonSelected["Settings"] != null ? Colors.red : const Color.fromRGBO(255, 255, 255, 0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //* Help
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Help",
                                style: TextStyle(
                                  fontWeight: headerButtonSelected["Help"] != null ? FontWeight.w600 : FontWeight.normal,
                                  fontFamily: "BerkshireSwash",
                                  fontSize: 18,
                                  color: headerButtonSelected["Help"] != null ? Colors.red : const Color.fromRGBO(255, 255, 255, 0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //* Search bar
                        SizedBox(
                          width: 220,
                          height: 45,
                          child: SearchAnchor.bar(
                            barBackgroundColor: MaterialStatePropertyAll(backgroundColor),
                            barLeading: const Text(""),
                            barHintText: "Search",
                            barHintStyle: const MaterialStatePropertyAll(TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: "BerkshireSwash",
                            )),
                            barTextStyle: const MaterialStatePropertyAll(TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
                            barTrailing: const [
                              Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                            ],
                            viewHeaderHintStyle: const TextStyle(
                              color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: "BerkshireSwash",
                            ),
                            viewHeaderTextStyle: const TextStyle(
                              color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                            ),
                            viewBackgroundColor: backgroundColor,
                            viewHintText: "Search",
                            viewLeading: IconButton(
                              onPressed: (){
                                Navigator.pop(context);    
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            viewConstraints: const BoxConstraints(
                              minWidth: 220,
                              maxHeight: 300,
                            ),
                            suggestionsBuilder: ((context, controller) {
                              return List<Widget>.generate(
                                5, 
                                (index) {
                                  return ListTile(
                                    textColor: Colors.white,
                                    titleAlignment: ListTileTitleAlignment.center,
                                    title: Text("Testings $index"),
                                    // selected: ,
                                    // selectedColor: ,
                                    // selectedColor: ,
                                    onTap: () {
                                      controller.closeView("$index");
                                      controller.text = "";
                                      // TODO: remove focus from the textfield when user have chosen a item
                                    },
                                  );
                                
                              });                              
                            }),
                          )
                        )

                      ],
                    ),
                    //* Tab Name
                    Container(
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
                          // TODO: should be dropdownmenu button instead
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
                                Icons.more_vert,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // This can be removed or moved inside of the dropdownmenu iconbutton
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Overview",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        Text(
                          "Statistics",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                    //* Program List
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      decoration: BoxDecoration(
                        color: boxInnerColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "Program list",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "BerkshireSwash",
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              const Spacer(flex: 2),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 4, 10, 0),
                                child: IconButton(
                                  onPressed: (){},
                                  icon: const Icon(Icons.more_vert),
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            flex: 8,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
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
                          ),
                          Expanded(
                            flex: 1,
                            child: tempMap.isEmpty ? 
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ElevatedButton(
                                onPressed: (){
                                  
                                  Navigator.of(context).push(ActiveProgramSelection(
                                    dataList: dataList["tab_list"][currentTab]["program_list"],
                                    onSaved: (saved){
                                                        
                                      for (var program in saved) {
                                                        
                                        String iconName = "i_${program["name"].split(".")[0]}.png";
                                        File file = File("assets/program_icons/$iconName");
                                                        
                                                        
                                        if (!file.existsSync()){
                                                        
                                          var memoryImageInBytes = program["icon"].image.bytes;
                                          file.writeAsBytesSync(memoryImageInBytes);
                                          
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
                                                        
                                        // TODO: Snackbar or showdialog to ask if the user wants to remove the existing program in the list?
                                        // thinking more like a undo button. instead of a popup for confirmation.
                                                        
                                      }
                                                        
                                      
                                      setState((){
                                        writeJsonFile(dataList);
                                      });
                                                        
                                    },
                                  ));
                                                        
                                                        
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    )
                                  )
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.black,
                                  size: 20,
                                )
                              ),
                            ) :
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ElevatedButton(
                                onPressed: (){
                                                        
                                  var currentProgramList = dataList["tab_list"][currentTab]["program_list"];
                                  List<Map<String, dynamic>> iconsInUseList = [{"name": "allPrograms.exe", "icon": "assets/program_icons/i_allPrograms.png"}];
                                                        
                                                        
                                  // Checking whether the other tabs is using a icons that is being removed
                                  for (var i = 0; i < dataList["tab_list"].length; i++) {
                                    
                                    var tab = dataList["tab_list"][i];
                                                        
                                    if (currentTab != i && tab["program_list"].isNotEmpty){
                                                        
                                      for (var j = 0; j < tab["program_list"].length; j++) {
                                                        
                                        var programName = tab["program_list"][j]["name"];
                                        
                                        if (tempMap.values.toString().contains("$programName") && !iconsInUseList.contains(programName)){
                                                        
                                          iconsInUseList.add(tab["program_list"][j]);
                                          break;
                                                        
                                        }
                                                        
                                      }
                                                        
                                    }
                                                        
                                  }
                                                        
                                                        
                                  for (var program in tempMap.values) {
                                                        
                                    var index = currentProgramList.indexOf(program);
                                    currentProgramList.removeAt(index);
                                                        
                                    // Remove icon that are not in use
                                    if (!iconsInUseList.toString().contains("$program")){
                                     
                                      File(program["icon"]).delete();
                                                        
                                    }
                                    
                                  }
                                  
                                  tempMap.clear();
                                                        
                                  dataList["tab_list"][currentTab]["program_list"] = currentProgramList;
                                  setState(() {  
                                    writeJsonFile(dataList);
                                    winManager.cancelTimer();
                                    winManager.monitorActiveWindow();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(255, 0, 0, 1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    )
                                  )
                                ),
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.black,
                                  size: 20,
                                )
                              ),
                            ),
                          )
                        ]
                      ),
                    ),
                    //* Options
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.blueGrey,
                              // TODO: how do i make this tab-specific from tab list
                              // meaning that if tab 1 has input opened and tab 2 has timer opened
                              // it should switch between them
                              child: Column(
                                children: [
                                  TabBar(
                                    controller: _optionsTabController,
                                    onTap: (index){
                                      dataList["tab_list"][currentTab]["options"]["tab_index"] = index;
                                      setState(() {
                                        writeJsonFile(dataList);
                                      });
                                    },
                                    tabs: const [
                                      // TODO: FIX THE LOOK+text, remove the underline
                                      Tab(
                                        text: "Input",
                                      ),
                                      Tab(
                                        text: "Timer",
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.blueGrey,
                                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: TabBarView(
                                        controller: _optionsTabController,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                                                margin: const EdgeInsets.fromLTRB(17, 0, 17, 10),
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
                                                        duration: const Duration(milliseconds: 2300),
                                                        width: 400,
                                                        backgroundColor: Colors.white,
                                                        behavior: SnackBarBehavior.floating,
                                                        action: SnackBarAction(
                                                          label: "Undo",
                                                          textColor: Colors.black,
                                                          onPressed: (){
                                                            //! Dont know how I should do this!??!
                                                            // when undo is pressed I should revert to previous value??
                                                          },
                                                        ),
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
                                                        // TODO: LATER: Move this into scaffoldmessenger later, when I figured out
                                                        // how I wanna do it.
                                                        setState(() {
                                                          writeJsonFile(dataList);
                                                          textController.text = value;
                                                        });
                                                        
                                                        //Updating the monitor dataList
                                                        winManager.cancelTimer();
                                                        winManager.monitorActiveWindow();
                                              
                                                        // Writes to database after snackBar is closed in case of undo
                                                        ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_value){
                                              
                                              
                                              
                                                        });
                                                        
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
                                              //* Repeat option
                                              Expanded(
                                                child: GridView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 7,
                                                    crossAxisSpacing: 10.0,
                                                  ),
                                                  itemCount: 7,
                                                  itemBuilder: (context, index) {
                                                    return Column(
                                                      children: [
                                                        Checkbox(
                                                          hoverColor: Colors.transparent,
                                                          splashRadius: 0,
                                                          fillColor: dataList["tab_list"][currentTab]["options"]["input"]["$index"] ? 
                                                          const MaterialStatePropertyAll(Color.fromRGBO(255, 199, 0, 1)) :
                                                          const MaterialStatePropertyAll(Color.fromRGBO(78, 83, 88, 1)),
                                                          checkColor: Colors.black,
                                                          side: const BorderSide(
                                                            color: Colors.black,
                                                          ),
                                                          value: dataList["tab_list"][currentTab]["options"]["input"]["$index"],
                                                          onChanged: (value){
                                                        
                                                            dataList["tab_list"][currentTab]["options"]["input"]["$index"] = value;
                                                            setState(() {
                                                              writeJsonFile(dataList);
                                                            });
                                                        
                                                          }
                                                        ),
                                                        Text(
                                                          daysOftheWeek[index],
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontFamily: "BerkshireSwash",
                                                            color: Colors.white,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                ),
                                              )
                                            ],
                                          ),
                                          // TODO: Finish the design for the Timer tab in figma
                                          const Column(
                                            children: [
                                              Icon(Icons.account_balance),
                                            ],
                                          ),
                                        ],
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              color: Colors.amber,
                              child: const Column(
                                children: [
                                  Text(
                                    "Hello",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            //* RIGHT "box"
            Expanded(
              flex: 3,
              child: Container(
                color: const Color.fromRGBO(39, 43, 47, 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //* Account
                          Container(
                            height: 95,
                            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {

                                  },
                                  icon: const Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(flex: 2),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "John Doe",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "BerkshireSwash",
                                      ),
                                    ),
                                    Text(
                                      "JohnDoe@email.com",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 0.7),
                                        fontSize: 10,
                                        fontFamily: "BerkshireSwash",
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 60,
                                    height: 50,
                                    color: Colors.grey, // temporary
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

                          //* Tab LIST
                          const Divider(
                            thickness: 2.5,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          const Center(
                            child: Text(
                              "Tab list",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontFamily: "BerkshireSwash",
                              ),
                            )
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            flex: 8,
                              child: RawScrollbar(
                                padding: const EdgeInsets.fromLTRB(0, 5, 8, 3),
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
                                  // TODO: Able to reorder with long press or draw...
                                  child: ReorderableListView.builder(
                                    buildDefaultDragHandles: false,
                                    padding: const EdgeInsets.fromLTRB(16, 3, 28, 0),
                                    scrollController: _scrollController,
                                    onReorder: (oldIndex, newIndex) {
                                      if (oldIndex < newIndex){
                                        newIndex -= 1;
                                      }
                                      final Map item = dataList["tab_list"].removeAt(oldIndex);
                                      dataList["tab_list"].insert(newIndex, item);
                                                                
                                      
                                      if (currentTab == oldIndex) {
                                        currentTab = newIndex;
                                      } else if (oldIndex < currentTab && newIndex >= currentTab) {
                                        currentTab--;
                                      } else if (oldIndex > currentTab && newIndex <= currentTab) {
                                        currentTab++;
                                      }
                                                                
                                      print("after: $currentTab");
                                                                
                                                                
                                      setState(() {
                                        writeJsonFile(dataList);
                                      });
                                  
                                    },
                                    itemCount: dataList["tab_list"].length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        key: Key("$index"),
                                        child: ReorderableDragStartListener(
                                          index: index,
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
                                                && !options["input"].values.contains(true)
                                                && options["time"] != null ){
                                                                                          
                                                  dataList["tab_list"][index]["active"] = !dataList["tab_list"][index]["active"];
                                                  // print("Valid");
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
                                            hoverColor: Colors.transparent,
                                            splashColor: Colors.transparent,
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
                                                _optionsTabController.animateTo(dataList["tab_list"][currentTab]["options"]["tab_index"]);
                                                removeOverlay();
                                              });
                                            },
                                            contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            textColor: Colors.deepPurple,
                                            iconColor: Colors.deepPurple,
                                            tileColor: currentTab == index ?
                                            const Color.fromRGBO(255, 199, 0, 1.0) :
                                            const Color.fromRGBO(245, 245, 245, 1.0),
                                            
                                            title: Text(
                                              dataList["tab_list"][index]["name"],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                color: Colors.black,
                                                // fontWeight: FontWeight.bold,
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
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ) 
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: SizedBox(
                                width: 95,
                                height: 35,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onPressed: () {
                                    
                                    dummyMap = {
                                      "name": "Tab ${dataList["tab_list"].length + 1}",
                                      "active": false,
                                      "program_list": [],
                                      "options": {
                                        "time": "",
                                        "tab_index": 0,
                                        "input": [
                                         false,
                                         false,
                                         false,
                                         false,
                                         false,
                                         false,
                                         false,
                                        ],
                                        "timer": ""
                                      }
                                    }; 
                                    dataList["tab_list"].add(dummyMap);
                                    setState(() {
                                      writeJsonFile(dataList);
                                    });
                                              
                                  },
                                  child: const Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      fontFamily: "KeaniaOne",
                                    ),
                                  ),
                                ),
                              ),
                            )
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 3,
                      height: 0,
                    ),
                    Divider(
                      color: borderColor,
                      thickness: 10,
                      height: 10,
                    ),
                    //* Bottom right box
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(8),
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
                ),
              )
            ),
          ],
        )
      ),
    );
  }

}
