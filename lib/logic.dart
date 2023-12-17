// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ffi';

import 'package:app_blocker/gridview_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart_functions.dart';

import "package:ffi/ffi.dart";
import 'package:win32/win32.dart';


class ActiveWindowManager{
  Timer? _timer;
  static String _lastChild = "";
  static int currentHwnd = 0;
  static String? exePath;

  static Map allActiveProgramsList = {};
  static List filterProgram = [
    "ApplicationFrameHost.exe",
    "explorer.exe",
    "TextInputHost.exe",
  ];



  static int _enumWinProc(int hwnd, int lParam){
    
    if (IsWindowVisible(hwnd) == 1){
      
      int style = GetWindowLongPtr(hwnd, GWL_STYLE);
      _getExePathfromHWND(hwnd);

      if (exePath!.contains(".exe") 
      && style & WS_CAPTION != 0
      && !filterProgram.contains(exePath)
      // && !allActiveProgramsList.containsValue(exePath) 
      ){
        final length = GetWindowTextLength(hwnd);
        if (length == 0) return TRUE;
        
        final buffer = wsalloc(length + 1);
        GetWindowText(hwnd, buffer, length + 1);
        
        final title = buffer.toDartString();
        free(buffer);

        allActiveProgramsList[title] = exePath;
        
      }
    }

    return TRUE;
  }

  List getAllActivePrograms(List dataList){
    
    final winproc = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
    EnumWindows(winproc, 0);
    
    List convertedList = [];
    allActiveProgramsList.forEach((key, value) {
      if (!dataList.contains(value)){
        convertedList.add(value);
      }
    });


    
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
      for (var j = 0; j < storageList[i]["program_list"].length; j++) {

        // ApplicationFrameHose.exe it's child
        if (_lastChild != "" && storageList[i]["program_list"][j] == _lastChild) {
          
          SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
          break;

        } else if (storageList[i]["program_list"][j] == exePath) { 
          
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

  static bool conditionChecks(List repeatOptions, List timePeriods, DateTime timeNow){
    
    //TODO: maybe create variable outside the function and inside the class, maybe?
    var timeNowFormatted = int.parse(DateFormat("HHmm").format(timeNow));
    int counter = 0;
    
    for(var dataTime in timePeriods){

      if (timeNowFormatted >= dataTime[0] && timeNowFormatted <= dataTime[1]){
        // print("within time periods");
        break;
        
      } else {
        // print("outside of time periods");
        counter ++; // valid time periods count
      }

    }

    if (counter == timePeriods.length){
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

  //! Cant show exe+/path of task manager, not showing up as anything.
  //! not very accurate and reliable but works most of the time. 
  //! when it checks the "ApplicationFrameHost.exe" <- it's not fast enough.
  //! Maybe I can optimize it or something.
  // TODO: Optimize the "ApplicationFrameHost.exe"?

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
    
    //* Could try to switch it to only check conditions if a program 
    //* match in the data list is/are true.

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
          _getExePathfromHWND(currentHwnd);

          for (var tab in validDataTabs){
            bool condition = conditionChecks(tab["options"]["repeat"], timePeriods, timeNow);
            if (!condition){
              _matchAndMinimize(currentHwnd, validDataTabs);
            } 
          }
          
        }
        
        //! maybe a done message for removing the loading screen?
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
    final List currentActivePrograms = ActiveWindowManager().getAllActivePrograms(dataList);
    
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width / 3,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          //TODO: change the color to be the same as program box/list
          color: const Color.fromRGBO(42, 46, 50, 1),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Colors.white,
          //     offset: Offset(-8, 8),
          //     blurRadius: 8.0,
          //     blurStyle: BlurStyle.inner
          //   )
          // ],
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
              Expanded(
                flex: 9,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(53, 53, 53, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomGridView(
                    itemCount: currentActivePrograms.length,
                    programNames: currentActivePrograms,
                    onSelectedChanged: (onSelectedChanged){
                      print(onSelectedChanged);
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
                      onPressed: (){
                        // send back to main? callback from onSelectedChanged value of CustomGridView

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