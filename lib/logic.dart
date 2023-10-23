import 'dart:convert';
import 'dart:ffi';
import 'dart:io';


import "package:ffi/ffi.dart";
// import 'package:flutter/services.dart';
import 'package:win32/win32.dart';



/// Class containing information about a window and related functions.
class Window {
  ///Title of the window.
  final String title;

  ///If the window is the active window or not.
  final bool isActive;

  ///Window ID.
  final int hWnd;

  // Process ID of the window
  final int processID;

  ///Full path the to executable of the window (Path to the exe file).
  final String? exePath;

  const Window({
    required this.title,
    required this.isActive,
    required this.hWnd,
    required this.processID,
    this.exePath,
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

int _enumWindowsProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == TRUE) {
    final length = GetWindowTextLength(hWnd);
    final buffer = wsalloc(length + 1);

    GetWindowText(hWnd, buffer, length + 1);

    final int processID = getProcessID(hWnd);
    final String exePath = getExePathfromPID(processID);
    bool isActive = GetForegroundWindow() == hWnd;
    final String title = buffer.toDartString();
    _list.add(Window(
        title: title,
        isActive: isActive,
        hWnd: hWnd,
        processID: processID,
        exePath: exePath));
    free(buffer);
  }
  return TRUE;
}

  // Future<void> readJson() async{

  // final String response = await rootBundle.loadString('assets/data.json');
  // Map<String, dynamic> myMap = await json.decode(response);
  // List<dynamic> myList = myMap["exe_list"];
  // // stderr.write("something got printed: $myMap \n");
  // // stderr.write("something got printed: $myList \n");

  
  

  // }

int _enumChildren(int hWnd, int lParam) {
  final int processID2 = getProcessID(hWnd);
  
  if (lParam != processID2) {
    
    final String exePath2 = getExePathfromPID(processID2);

    // _list.add(Widnow(exePath: exePath2, processID: processID2, title: "", isActive: false, hWnd))
    stdout.write("$lParam | $exePath2 | $processID2 \n");

  }
  

  
  return TRUE;
}



int _enumChildProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == TRUE) {
    final length = GetWindowTextLength(hWnd);
    final buffer = wsalloc(length + 1);

    GetWindowText(hWnd, buffer, length + 1);
    final String title = buffer.toDartString();
    final int processID = getProcessID(hWnd);
    final String exePath = getExePathfromPID(processID);

    final List path = exePath.split("\\");
    final String last = path.last; // need for matching the chosen program
    // stdout.write("$last \n");

    // stdout.write("$title | $hWnd | $processID | $exePath \n");

    
    // put this above the other lines
    if (last == "ApplicationFrameHost.exe") {

      // stdout.write("somethign if $processID ");

      final winproc3 = Pointer.fromFunction<EnumWindowsProc>(_enumChildren, 0);
      EnumChildWindows(hWnd, winproc3, processID);

      
      free(buffer);
      return TRUE;
      
    }
    

    
    

  }
  return TRUE;
}

void main() {

  final winproc2 = Pointer.fromFunction<EnumWindowsProc>(_enumChildProc, 0);
  EnumWindows(winproc2, 0);



}





void logic() {
  final winProc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
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
