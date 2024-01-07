// ignore_for_file: avoid_print, constant_identifier_names

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:app_blocker/gridview_custom.dart';
import 'package:flutter/material.dart';
import 'dart_functions.dart';

import "package:image/image.dart" as img;
import 'package:intl/intl.dart';
import "package:ffi/ffi.dart";
import 'package:win32/win32.dart';


class ActiveWindowManager{

  Timer? _timer;

  static String _lastChild = "";

  static int currentHwnd = 0;

  static String? exePath;

  static String? fullPath;

  static img.Image? imageIcon;

  static List allActiveProgramsList = [];

  static List filterProgram = [
    "ApplicationFrameHost.exe",
    "explorer.exe",
    "TextInputHost.exe",
  ];
  


  static void iconToImage(int hwnd) {    

    // if (fullPath!.contains("WindowsApp")){
    //   print("icontoImage: $exePath $fullPath ");
    // }

    final fileInfo = calloc<SHFILEINFO>();
    const SHGFI_LARGEICON = 0x000000000;
    const SHGFI_ICON = 0x000000100;

    
    SHGetFileInfo(fullPath!.toNativeUtf16(), 0, fileInfo, sizeOf<SHFILEINFO>(), 
    SHGFI_ICON | SHGFI_LARGEICON);

    final hIcon = fileInfo.ref.hIcon;

    // TODO: LATER: fix the windows app icon, not able to show the correct one.
    // var hIcon = GetClassLongPtr(hwnd, GCL_HICON);
    // if (fullPath!.contains("WindowsApp")){

    // }
    // if (hIcon == 0) {
    //   print("here");
    //   hIcon = SendMessage(hwnd, WM_GETICON, 2, 0);
    // }
    // print(hIcon);


    final iconInfo = calloc<ICONINFO>();
    GetIconInfo(hIcon, iconInfo);


    final hdc = GetDC(0);
    final hBitmap = iconInfo.ref.hbmColor;

    
    final bitmap = calloc<BITMAP>();
    GetObject(hBitmap, sizeOf<BITMAP>(), bitmap);
    
    final bitmapInfo = calloc<BITMAPINFOHEADER>()
      ..ref.biSize = sizeOf<BITMAPINFOHEADER>()
      ..ref.biWidth = bitmap.ref.bmWidth
      ..ref.biHeight = -bitmap.ref.bmHeight
      ..ref.biPlanes = 1
      ..ref.biBitCount = 32
      ..ref.biCompression = BI_RGB;



    int bufferSize = bitmap.ref.bmWidth * bitmap.ref.bmHeight * 4;
    final buffer = calloc<Uint8>(bufferSize);
    GetDIBits(hdc, hBitmap, 0, bitmapInfo.ref.biHeight, buffer, bitmapInfo.cast(), DIB_RGB_COLORS);
    
    
    final alphaBuffer = calloc<Uint8>(bufferSize);
    for (var i = 0; i < bufferSize; i += 4) {
      final alpha = buffer[i + 3];
      
      // Copy BGR channels instead of RGB channels
      alphaBuffer[i] = buffer[i + 2]; // Blue
      alphaBuffer[i + 1] = buffer[i + 1]; // Green
      alphaBuffer[i + 2] = buffer[i]; // Red
      alphaBuffer[i + 3] = alpha; // Alpha
    }


    imageIcon = img.Image.fromBytes(
      width: 32,
      height: 32,
      numChannels: 4,
      bytes: alphaBuffer.asTypedList(bufferSize).buffer
    );
    

    free(fileInfo);
    DestroyIcon(fileInfo.ref.hIcon);
    DestroyIcon(hIcon);
    DeleteObject(iconInfo.ref.hbmColor);
    DeleteObject(iconInfo.ref.hbmMask);
    free(iconInfo);
    free(bitmapInfo);
    free(bitmap);
    free(buffer);
    free(alphaBuffer);


  }

  static int _enumWinProc(int hwnd, int lParam){
    
    if (IsWindowVisible(hwnd) == 1){
      
      int style = GetWindowLongPtr(hwnd, GWL_STYLE);
      _getExePathfromHWND(hwnd);

      if (exePath!.contains(".exe") 
      && style & WS_CAPTION != 0
      && !filterProgram.contains(exePath)
      ){
        //! Can be removed If needed to be: title
        final length = GetWindowTextLength(hwnd);
        if (length == 0) return TRUE;
        
        // final buffer = wsalloc(length + 1);
        // GetWindowText(hwnd, buffer, length + 1);
        
        // final title = buffer.toDartString();
        // free(buffer);

        iconToImage(hwnd);
        allActiveProgramsList.add({
          "name": exePath, //Name of the program; "Notion.exe"
          "icon": imageIcon
        });
        // allActiveProgramsList[title] = exePath;
        
      }
    }

    return TRUE;
  }

  List getAllActiveProgramsWithIcon(List dataList){
    
    final winproc = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
    EnumWindows(winproc, 0);
    
    
    List convertedList = [];
    List uniqueList = [];
    List dataListNames = []; // To not show already added programs

    for (var i = 0; i < dataList.length; i++) {
      dataListNames.add(dataList[i]["name"]);
    }
    

    for (var i = 0; i < allActiveProgramsList.length; i++){
      String name = allActiveProgramsList[i]["name"];
      Map mapNameAndIcon = allActiveProgramsList[i];


      if (!uniqueList.contains(name) && !dataListNames.contains(name)) {
        uniqueList.add(name);
        convertedList.add(mapNameAndIcon);
      }
      
    }

    return convertedList;

  }

  static void _getExePathfromHWND(int hWnd) {
    final int processID = getProcessID(hWnd);
    final int hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);


    final LPWSTR imgName = wsalloc(MAX_PATH);
    final Pointer<Uint32> buff = calloc<Uint32>()..value = MAX_PATH;
    if (QueryFullProcessImageName(hProcess, 0, imgName, buff) != 0) {
      final LPWSTR szModName = wsalloc(MAX_PATH);
      GetModuleFileNameEx(hProcess, 0, szModName, MAX_PATH);
      exePath = szModName.toDartString();
      free(szModName);
    } else {
      exePath = "";
    }

    free(imgName);
    free(buff);
    CloseHandle(hProcess);
    
    fullPath = exePath;
    exePath = exePath!.split("\\").last;
    
    
    if (exePath == "ApplicationFrameHost.exe"){
      final winProc = Pointer.fromFunction<EnumWindowsProc>(_enumWinChildren, 0);
      EnumChildWindows(hWnd, winProc, processID);
    }

  }


  static int getProcessID(int hWnd) {
    final Pointer<Uint32> pId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, pId);
    final int processID = pId.value;
    free(pId);
    return processID;
  }


  static int _enumWinChildren(int hWnd, int pID) {
    final int processID2 = getProcessID(hWnd);

    if (pID != processID2) {
      _getExePathfromHWND(hWnd);
      _lastChild = exePath!;
      return FALSE;
    }

    return TRUE;
  }

  
  static void _matchAndMinimize(int hWnd, List storageList) {
    
    // Loops through all the active tabs.
    for (var i = 0; i < storageList.length; i++) {
      for (var j = 0; j < storageList[i]["program_list"].length; j++) {

        // ApplicationFrameHose.exe; it's child
        if (_lastChild != "" && storageList[i]["program_list"][j]["name"] == _lastChild) {
          
          SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
          break;

        } else if (storageList[i]["program_list"][j]["name"] == exePath) { 
          
          // ShowWindow(hWnd, 11);
          SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
          break;

        }
      }
    }
  }

  void cancelTimer(){
    if(_timer != null){
      _timer!.cancel();
    }
  }

  static bool conditionCheck(List repeatOptions, List timePeriods, DateTime timeNow){
    
    var timeNowFormatted = int.parse(DateFormat("HHmm").format(timeNow));
    int notWithinTimePeriodsCount = 0;
    
    for(var dataTime in timePeriods){

      if (timeNowFormatted >= dataTime[0] && timeNowFormatted <= dataTime[1]){
        //within time periods;
        break;
        
      } else {
        //outside of time periods;
        notWithinTimePeriodsCount++;
      }

    }

    if (notWithinTimePeriodsCount == timePeriods.length){
      return false;
    }

    switch (repeatOptions[0]) {
      case "Daily":
        //Check only time
        return true;
      case "Weekdays":
      case "Weekly":
        //Check the day>time
        var weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri",];
        var weekly = repeatOptions.length >= 2 ? repeatOptions[1] : null;
        var dayNowFormatted = DateFormat("E").format(timeNow);
        
        if (weekly == dayNowFormatted || weekDays.contains(dayNowFormatted)){
          return true;
        }
        return false;

      case "Custom":
        //* Should try to make it work, seeing as I might use something similar in the todo project.
        //Check the date>time
        // maybe add another item
        /*
        Custom
        2
        weeks
        {
            "0": "Mon",
            "1": "Tue",
            "2": "Wed",
            "3": "Thu",
            "4": "Fri",
            "5": "Sat",
            "6": "Sun"
        }
        */
        // Need a field/box to show next due date
        // cal 2 "weeks" into days, re-cal if the dateNowFormatted is true
        // dateNow.add(const Duration(days: n))


        return false;
      default:
        //Error?
    }
    print("It shouldnt get to here... Maybe Error?");
    return false;
  }

  // TODO: LATER: change to SetWinEventHook. Dont know if its better to switch. 
  // Seems to work pretty decently right.

  void monitorActiveWindow() async {
    final List storageList = readJsonFile()["tab_list"];
    

    DateTime timeNow = DateTime.now();
    List validDataTabs = [];

    for ( var tab in storageList) {
      if ( tab["program_list"].isEmpty
      || tab["options"]["time"].isEmpty
      || tab["options"]["repeat"].isEmpty
      || tab["active"] == false){
        continue;
      }
      
      validDataTabs.add(tab);
    }
    

    if (validDataTabs.isNotEmpty) {

      List timePeriods = [];

      for (var index = 0; index < validDataTabs.length; index++){

        var splitTimeData = validDataTabs[index]["options"]["time"].split(RegExp(r"[\,]")); //"1000-1100,1200-1300".split...

        for (var time in splitTimeData){

          var intRange = time.split("-").map((item) => int.parse(item)).toList();
          timePeriods.add(intRange);

        }
        
      }
      
         
      _timer = Timer.periodic(const Duration(microseconds: 50000), (timer) {

        timeNow = DateTime.now();


        if (currentHwnd != GetForegroundWindow()) {
          
          currentHwnd = GetForegroundWindow();

          _lastChild = "";
          _getExePathfromHWND(currentHwnd); // Used for matching against database/storage

          for (var tab in validDataTabs){
            
            bool condition = conditionCheck(tab["options"]["repeat"], timePeriods, timeNow);

            // TODO: FEATURE: the settings for blocking outside of time periods is true 
            // then just replace "condition" with "!condition". Instead of the default, 
            // blocking within time periods.
            if (condition){
              _matchAndMinimize(currentHwnd, validDataTabs);
            } 
          }
          
        }
        
        //! maybe a done message to remove the loading screen?
      });
    }

  }
    

}

class ActiveProgramSelection extends PopupRoute {

  ActiveProgramSelection({
    required this.dataList,
    required this.onSaved,
  });

  final List dataList;
  final void Function(List) onSaved;
  
  
  List selectedList = [];
  

  @override
  Color? get barrierColor => Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 30);
  

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {

    final List<dynamic> currentActivePrograms = ActiveWindowManager().getAllActiveProgramsWithIcon(dataList);
    currentActivePrograms.insert(0, {
      "name": "All Programs.exe",
      "icon": "assets/program_icons/i_allprograms.png"
    });

    // Storing for when I'm re-building(setstate) during de+/selecting programs. Would otherwise cause "flickering"
    List imageList = [];
    for (var i = 1; i < currentActivePrograms.length; i++) {
      imageList.add(Image.memory(Uint8List.fromList(img.encodePng(currentActivePrograms[i]["icon"])), ));
      currentActivePrograms[i]["icon"] = imageList[i - 1];
    }

    
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width / 3,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(42, 46, 50, 1),
          border: Border.all(
            color: Colors.redAccent,
            width: 6.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Currently active programs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 22,
                    color: Color.fromRGBO(217, 217, 217, 1),
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(53, 53, 53, 1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1,
                      color: const Color.fromRGBO(200, 2000, 200, 1)
                    )
                  ),
                  child: CustomGridView(
                    itemCount: currentActivePrograms.length,
                    programNames: currentActivePrograms,
                    onSelectedChanged: (onSelectedChanged){

                      selectedList = onSelectedChanged.values.toList();

                    },
                  )
                )
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {


                        onSaved(selectedList);
                        Navigator.pop(context);
                        
                      },
                      child: const Text("Save/Add"),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}