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

  static List exceptions = [
    "Code.exe",
    "msedge.exe",
    "explorer.exe",
    "app_blocker.exe",
    "LockApp.exe",
  ];

  static List filterProgram = [
    "ApplicationFrameHost.exe",
    "explorer.exe",
    "TextInputHost.exe",
  ];


  // TODO: LATER: fix the windows app icon, not able to show the correct one.
  static void iconToImage(int hwnd) async {

    // if (fullPath!.contains("WindowsApp")){
    //   print("icontoImage: $exePath $fullPath ");
    // }


    final fileInfo = calloc<SHFILEINFO>();
    const SHGFI_LARGEICON = 0x000000000;
    const SHGFI_ICON = 0x000000100;

    
    SHGetFileInfo(fullPath!.toNativeUtf16(), 0, fileInfo, sizeOf<SHFILEINFO>(), 
    SHGFI_ICON | SHGFI_LARGEICON);

    final hIcon = fileInfo.ref.hIcon;


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
    

    imageIcon = img.Image.fromBytes(
      width: 32,
      height: 32,
      order: img.ChannelOrder.bgra,
      numChannels: 4,
      bytes: buffer.asTypedList(bufferSize).buffer
    );
    
    

    free(fileInfo);
    DestroyIcon(hIcon);
    DeleteObject(iconInfo.ref.hbmColor);
    DeleteObject(iconInfo.ref.hbmMask);
    free(iconInfo);
    free(bitmapInfo);
    free(bitmap);
    free(buffer);


  }

  static int _enumWinProc(int hwnd, int lParam) {
    
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
        
        iconToImage(hwnd);
        allActiveProgramsList.add({
          "name": exePath,
          "icon": imageIcon
        });
        
                
      }
    }

    return TRUE;
  }

  List getAllActiveProgramsWithIcon(List dataList){
    
    final winproc = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
    EnumWindows(winproc, 0);

    allActiveProgramsList.insert(0, {
      "name": "allPrograms.exe",
      "icon": "assets/program_icons/i_allPrograms.png"
    });
    

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

    allActiveProgramsList.clear();

    return convertedList;

  }

  static void _getExePathfromHWND(int hWnd) {
    final int processID = getProcessID(hWnd);
    final int hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);

    // TODO: cant find the hProcess for Task Manager

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

    
    for (var i = 0; i < storageList.length; i++) {

      // print("${storageList[i]["name"]} $exePath");
      

      if (storageList[i]["name"] == "allPrograms.exe" && !exceptions.contains(exePath)){

        final length = GetWindowTextLength(hWnd);
        final buffer = wsalloc(length + 1);
        GetWindowText(hWnd, buffer, length + 1);
        
        final title = buffer.toDartString();
        free(buffer);


        
        var test = title.split(" ").join("");
        // print(test.contains("TaskManager"));

        if (test.contains("TaskManager")){
          break;
        }


        // TODO: Exceptions unless checked in settings. 
        // will only work  when all program is picked.
        // Exceptions: For now: vscode, 
        // definitely: window explorer, taskmanager(?), LockApp.exe, app_blocker(?)

        SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        // print("block");
        break;
        
      } 

      // ApplicationFrameHost.exe; it's child(ren)
      if (_lastChild != "" && storageList[i]["name"] == _lastChild) {
        
        SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        break;

      } else if (storageList[i]["name"] == exePath) { 
        
        // ShowWindow(hWnd, 11);
        SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        break;

      }
      
    }

  }

  void cancelTimer(){
    if(_timer != null){
      _timer!.cancel();
    }
  }

  static bool conditionCheck(Map activeDays, List timePeriods, DateTime timeNow){

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

    
    var today = DateTime.now().weekday - 1; // Mon-Sun == 1-7

    for (var i = 0; i < activeDays.values.length; i++ ) {


      if (!activeDays["$i"]) {
        continue;
      }

      if (today == i){
        return true;
      }
      
    }
    
    return false;
    
  }

  // TODO: LATER: change to SetWinEventHook. Dont know if its better to switch. 
  // Seems to work pretty decently right.

  void monitorActiveWindow() async {
    final List storageList = readJsonFile()["tab_list"];
    

    DateTime timeNow = DateTime.now();
    List validDataTabs = [];

    for ( var tab in storageList) {
      if ( 
      tab["active"] == false
      || tab["program_list"].isEmpty
      || tab["options"]["time"].isEmpty
      || !tab["options"]["input"].values.contains(true)
      ){
        continue;
      }

      // So it doesnt do unnecessary checks.
      if (tab["program_list"][0]["name"] == "allPrograms.exe"){
        var addOnlyAllPrograms = tab["program_list"][0];
        tab["program_list"] = [addOnlyAllPrograms];
      }
      
      validDataTabs.add(tab);
    }
    

    if (validDataTabs.isNotEmpty) {

      List timePeriods = [];

      for (var index = 0; index < validDataTabs.length; index++){

        var splitTimeData = validDataTabs[index]["options"]["time"].split(RegExp(r"[\,]")); //"1000-1100,1200-1300".split...

        // validDataTabs[index]["options"]["repeat"].values

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

            bool condition = conditionCheck(tab["options"]["input"], timePeriods, timeNow);

            // TODO: FEATURE: the settings for blocking outside of time periods is true 
            // then just replace "condition" with "!condition". Instead of the default, 
            // blocking within time periods.
            if (condition){
              _matchAndMinimize(currentHwnd, tab["program_list"]);
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

    List<dynamic> currentActivePrograms = ActiveWindowManager().getAllActiveProgramsWithIcon(dataList);


    // Storing for when I'm re-building(setstate) during de+/selecting programs. Would otherwise cause "flickering"
    for (var i = 0; i < currentActivePrograms.length; i++) {

      if (currentActivePrograms[i]["name"] != "allPrograms.exe"){

        currentActivePrograms[i]["icon"] = Image.memory(Uint8List.fromList(img.encodePng(currentActivePrograms[i]["icon"])));

      }
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

                      if (onSelectedChanged.containsKey(0) && onSelectedChanged[0]["name"] == "allPrograms.exe"){

                        final allPrograms = selectedList[0];
                        selectedList.clear();
                        
                        selectedList.add(allPrograms);
                      }

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
                    const SizedBox(width: 15),
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