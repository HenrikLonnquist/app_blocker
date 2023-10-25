import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import "dart:core";


import "package:ffi/ffi.dart";
// import 'package:flutter/services.dart';
import 'package:win32/win32.dart';



/// Class containing information about a window and related functions.
class Window {
  ///Title of the window.
  final String? title;

  ///If the window is the active window or not.
  final bool? isActive;

  ///Window ID.
  final int? hWnd;

  // Process ID of the window
  final int? processID;

  ///Full path the to executable of the window (Path to the exe file).
  final String exePath;

  const Window({
    this.title,
    this.isActive,
    this.hWnd,
    this.processID,
    required this.exePath,
  });
}

final List<Window> _list = [];

String getExePathfromPID(int processID) {
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

int getProcessID(int hWnd) {
  final Pointer<Uint32> pId = calloc<Uint32>();
  GetWindowThreadProcessId(hWnd, pId);
  final int processID = pId.value;
  free(pId);
  return processID;
}
  // this is for flutter
  // Future<void> readJson() async{

  // final String response = await rootBundle.loadString('assets/data.json');
  // Map<String, dynamic> myMap = await json.decode(response);
  // List<dynamic> myList = myMap["exe_list"];
  // // stderr.write("something got printed: $myMap \n");
  // // stderr.write("something got printed: $myList \n");

  
  

  // }

int _enumChildren(int hWnd, int pID) {
  final int processID2 = getProcessID(hWnd);
  

  if (pID != processID2) {
    
    final String exePath2 = getExePathfromPID(processID2);

    _list.add(Window(exePath: exePath2, processID: processID2, hWnd: hWnd));
    // stdout.write("$pID | $exePath2 | $processID2 \n");



  }
  

  
  return TRUE;
}



int _enumWinProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == TRUE) {

    final length = GetWindowTextLength(hWnd);
    final buffer = wsalloc(length + 1);

    GetWindowText(hWnd, buffer, length + 1);
    final String title = buffer.toDartString();
    bool isActive = GetForegroundWindow() == hWnd;
    final int processID = getProcessID(hWnd);
    final String exePath = getExePathfromPID(processID);

    final List path = exePath.split("\\");
    final String last = path.last; // needed for matching the chosen program
    // stdout.write("$last \n");

    // stdout.write("$title | $hWnd | $processID | $exePath \n");
    // stdout.write("$processID | $last \n");

    
    if (last == "ApplicationFrameHost.exe") {
      
      final winproc3 = Pointer.fromFunction<EnumWindowsProc>(_enumChildren, 0);
      EnumChildWindows(hWnd, winproc3, processID);
            
      // _list.add(Window(
      //   title: title, 
      //   isActive: isActive,
      //   hWnd: hWnd, 
      //   processID: processID, 
      //   exePath: exePath
      // ));
      free(buffer);
      return TRUE;

   }
    
    _list.add(Window(
      title: title, 
      isActive: isActive,
      hWnd: hWnd, 
      processID: processID, 
      exePath: exePath
      ));
    free(buffer);
  }
  return TRUE;
}

Future<List> readJsonFile(String filePath) async {

  var input = await File(filePath).readAsString();
  var jsonData = const JsonDecoder().convert(input);
  return jsonData["exe_list"];

}


// find the window that needs to be minimized from the handle
void _minimizeWin(int hWnd) {

  // only if the blocking conditions are true will it "block"; minimize

  // if  
  


  // 0 == SW_HIDE --> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
  // ShowWindow(hWnd, 0);
  
  // if (IsIconic(hWnd) == FALSE) throw Exception("Window is not minimized");

}

// Finds if the actives windows(opened programs) are in the list of programs to block(minimize)
void matchingExe(List exeList) {

    // stdout.write("$exeList \n");
    var copyWinExeList = [];

    for (var i = 0; i < _list.length; i++) {
      final Window win = _list[i];
      // stdout.write("${win.title} | ${win.isActive} | hwnd: ${win.hWnd} | pID: ${win.processID} | ${win.exePath}\n");
      copyWinExeList.add(win.exePath);
    }

    final noDup = copyWinExeList.toSet().toList();
    // for (var element in noDup) {
    //   stdout.write("$element \n");
    // }

    for (var i = 0; i < exeList.length; i++) {
      final String exeName = exeList[i];
      for (var j = 0; j < noDup.length; j++) {
        final String winName = noDup[j].split("\\").last;
        if (winName == exeName) {
          stdout.write("Inside if | ${winName == exeName} | $winName | $exeName \n");
          // need to do something here if it matches.
          // and check for blocking conditions for that particular program.
          // blocking conditions: Timer reaches zero, no timer, "clock/schedule based", 
          break;
        
        }
        stdout.write("Outside if | ${winName == exeName} | $winName | $exeName \n");
        

      }
    }
  }

Future<void> main() async {

  // get the active windows and their executables path
  final winproc2 = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
  EnumWindows(winproc2, 0);

  // match the active windows exe path with list from json file
  final List exeList = await readJsonFile(
    "C:\\Users\\henri\\Documents\\Programming Projects\\Flutter Projects\\app_blocker\\assets\\data.json").then((value) => value);

  // matching the lists and opened programs, at the same time will minimize or
  // or close those that meet the blocking conditions.
  matchingExe(exeList);

  _minimizeWin(0);

  exit(0);
}





void logic() {
  final winProc = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
  EnumWindows(winProc, 0);

  for (var win in _list) {
    if (win.title != "") {
      stderr.write(
          "${win.title} | ${win.isActive} | hwnd: ${win.hWnd} | pID: ${win.processID} | ${win.exePath}\n");
    }
  }

  // List dataItems = [];


  // dataItems.add(readJson());

  // stderr.writeln(dataItems);



  exit(0);
}
