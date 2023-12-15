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
  late Timer _timer;
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

  
  void _matchAndMinimize(int hWnd, List storageList, String last, int index) {

    
    // print("match: $storageList[index]");

    // TODO: read the options/conditions for closing/minimizing/blocking program
    // ! Do i do conditions first or match programs first? = Condition first
    // ! maybe not do condition here but where the Timer function is.
    // * So conditions first and match program while condition is true/false
    // Example: condition to block == 8.00-17.00 while this is true, it will monitor
    // programs for matches from the tab where the condition is true

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
    _timer.cancel();
  }

  //! Not necessary - can add this to the function later maybe.
  // Will check all the opened programs and then minimize if matches are found in the storage list
  // final winproc2 = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
  // EnumWindows(winproc2, 0);
  //* Could loop through all the windows every interval but maybe later.
  //! Cant show exe+/path of task manager, not showing up as anything.
  //! not very accurate and reliable but works most of the time. Sometimes it wont work 
  //! when it checks the "ApplicationFrameHost.exe" <- it's not fast enough.
  //! Maybe I can optimize it or something.
  // TODO: Optimize the "ApplicationFrameHost.exe"?

  void monitorActiveWindow() async {
    final List storageList = readJsonFile()["tab_list"];
    var currentHwnd = 0;
    int index = 0;
    
    DateTime timeNow = DateTime.now();
    
    String hourMin = DateFormat("HHmm").format(timeNow); // Daily: 2300 || only time
    String weekday = DateFormat("E").format(timeNow); // Weekly: Tue - 2300 || if Day -> time
    // String month = DateFormat("d/M").format(timeNow); // Monthly: 5(date) - 2300 || Date of the month - time
    // String year = DateFormat("d/M/y").format(timeNow); // Yearly: 12/5 || month/date - time 
    
    // print(hourMin);
    // print(weekday);
    // print(month);
    // print(year); 

    List validData = [];

    for ( var tab in storageList) {
      if ( tab["program_list"].isEmpty
      || tab["options"]["time"].isEmpty
      || tab["options"]["repeat"].isEmpty
      || tab["active"] == false){
        continue;
      }
      //TODO: maybe make sure when data is stored to validate then.
      //* Or I can have a active button to active the tab,
      validData.add(tab);
    }
    
    // print(validData);
    
    if (validData.isNotEmpty) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {


        timeNow = DateTime.now();
        // print(timeNow);
        print(validData);

        if (validData[0]["options"]["repeat"]){
          // Daily, Weekdays, Weekly, Custom
          
        }
        


        //TODO: make below a function instead
        if (currentHwnd == 0) {
          currentHwnd = GetForegroundWindow();
        }


        //! Do I gather all the conditions outisde of timer function in a variable?'
        //! or what? just loop inside here? Maybe I can make use of the timer function?
        // conditions = storageList[index]["condtions"]   -- havent thought of what to call it
        // or the structure for it; it also needs the take from the repeat option, not just the textformfield
        // I need to loop this
        // IF condition statement should wrap below
        // 


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

          _matchAndMinimize(currentHwnd, storageList, last, index);
          // stdout.write("Current program: ${_lastChild.isNotEmpty ? _lastChild : last} \n");
          
          
        }
      });
    }

  }
    

}

