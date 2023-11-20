import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'dart_functions.dart';

import "package:ffi/ffi.dart";
import 'package:win32/win32.dart';

// Why do I need this?
var _lastChild = "";

String _getExePathfromHWND(int hWnd) {
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

int getProcessID(int hWnd) {
  final Pointer<Uint32> pId = calloc<Uint32>();
  GetWindowThreadProcessId(hWnd, pId);
  final int processID = pId.value;
  free(pId);
  return processID;
}

int _enumChildren(int hWnd, int pID) {
  final int processID2 = getProcessID(hWnd);

  if (pID != processID2) {
    final String exePath2 = _getExePathfromHWND(hWnd);
    _lastChild = exePath2.split("\\").last;
  }

  return TRUE;
}

// Find matches if true the minimizes the window.
void _matchAndMinimize(int hWnd, List storageList, String last) {
  // only if the blocking conditions are true will it "block"; minimize

  // if

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

//! Not necessary - can add this to the function later maybe.
// Will check all the opened programs and then minimize if matches are found in the storage list
// final winproc2 = Pointer.fromFunction<EnumWindowsProc>(_enumWinProc, 0);
// EnumWindows(winproc2, 0);
//* Could loop through all the windows every interval but maybe later.
//! Cant show exe+/path of task manager, not showing up as anything.
//! not very accurate
void monitorActiveWindow() async {
  final List storageList = readJsonFile();
  var currentHwnd = 0;
  
  Timer.periodic(const Duration(milliseconds: 500), (timer) {

    if (currentHwnd == 0) {
      currentHwnd = GetForegroundWindow();
    }

    if (currentHwnd != GetForegroundWindow()) {
      final test = Stopwatch()..start();
      currentHwnd = GetForegroundWindow();

      _lastChild = "";
      final String exePath = _getExePathfromHWND(currentHwnd);
      final String last = exePath.split("\\").last;

      if (last == "ApplicationFrameHost.exe") {
        final int processID = getProcessID(currentHwnd);
        final winproc3 = Pointer.fromFunction<EnumWindowsProc>(_enumChildren, 0);
        EnumChildWindows(currentHwnd, winproc3, processID);
      }

      _matchAndMinimize(currentHwnd, storageList, last);
      stdout.write(
          "Current program: ${_lastChild.isNotEmpty ? _lastChild : last} \n");
      stdout.write("testing : ${test.elapsed.inMicroseconds}μs \n");
      test.stop();
    }
  });
}
