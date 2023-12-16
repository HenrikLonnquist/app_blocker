// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ffi';
// import 'dart:io';

import 'package:intl/intl.dart';

import 'dart_functions.dart';

import "package:ffi/ffi.dart";
import 'package:win32/win32.dart';

class ActiveWindowManager{
  // Why do I need this?
  Timer? _timer;
  static var _lastChild = "";

  static String _getExePathfromHWND(int hWnd) {
    final int processID = getProcessID(hWnd);
    final int hProcess = OpenProcess(
        PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID);

    final String exePath;
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

    return exePath;
  }

  static int getProcessID(int hWnd) {
    final Pointer<Uint32> pId = calloc<Uint32>();
    GetWindowThreadProcessId(hWnd, pId);
    final int processID = pId.value;
    free(pId);
    return processID;
  }

  static int _enumChildren(int hWnd, int pID) {
    final int processID2 = getProcessID(hWnd);

    if (pID != processID2) {
      final String exePath2 = _getExePathfromHWND(hWnd);
      _lastChild = exePath2.split("\\").last;
    }

    return TRUE;
  }

  
  static void _matchAndMinimize(int hWnd, List storageList, String last) {

    
    // print("match: $storageList[index]");

    for (var i = 0; i < storageList.length; i++) {
      if (_lastChild != "" && storageList[i] == _lastChild) {
        SendMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
        break;
      } else if (storageList[i] == last) {
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

  static bool conditionChecks(List repeatOptions, List timePeriods, DateTime timeNow){
    
    //TODO: maybe create variable outside the function and inside the class, maybe?
    var timeNowFormatted = int.parse(DateFormat("HHmm").format(timeNow));
    timeNowFormatted = 0619; //For testing
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

    if (counter >= 2){
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
      //TODO: remove custom and replace with an array of checkboxes of weekdays
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
        // cal 2 "weeks" into days, re-cal if the dateNowFormatted is true
        // dateNow.add(const Duration(days: n))


        return false;
      default:
        //Error?
    }
    print("It shouldnt get to here");
    return false;
  }


  static void blockPrograms(int currentHwnd, List storageList){
    if (currentHwnd == 0) {
      currentHwnd = GetForegroundWindow();
    }

    if (currentHwnd != GetForegroundWindow()) {
      
      currentHwnd = GetForegroundWindow();

      _lastChild = "";
      final String exePath = _getExePathfromHWND(currentHwnd);
      final String last = exePath.split("\\").last;

      if (last == "ApplicationFrameHost.exe") {
        final int processID = getProcessID(currentHwnd);
        final winproc3 = Pointer.fromFunction<EnumWindowsProc>(_enumChildren, 0);
        EnumChildWindows(currentHwnd, winproc3, processID);
      }

      //TODO: change storageList to validDataTabs inside a for-loop(maybe something else)?
      _matchAndMinimize(currentHwnd, storageList, last);
      // stdout.write("Current program: ${_lastChild.isNotEmpty ? _lastChild : last} \n");
      
      
    }
  }

  //! Not necessary - can add this to the function later maybe.
  // Will check all the opened programs and then minimize if matches are found in the storage list
  // final winproc2 = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
  // EnumWindows(winproc2, 0);
  
  //! Cant show exe+/path of task manager, not showing up as anything.
  //! not very accurate and reliable but works most of the time. 
  //! when it checks the "ApplicationFrameHost.exe" <- it's not fast enough.
  //! Maybe I can optimize it or something.
  // TODO: Optimize the "ApplicationFrameHost.exe"?

  void monitorActiveWindow() async {
    final List storageList = readJsonFile()["tab_list"];
    var currentHwnd = 0;

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
      
      
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {

        timeNow = DateTime.now();

        for (var tab in validDataTabs){
          bool block = conditionChecks(tab["options"]["repeat"], timePeriods, timeNow);
          if (block){
            blockPrograms(currentHwnd, validDataTabs);
          } 
        }

      });
    }

  }
    

}

