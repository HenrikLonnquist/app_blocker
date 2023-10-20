// import 'dart:ffi';
// import "dart:io";
// import 'dart:ui';

// import 'package:ffi/ffi.dart';
// import 'package:win32/win32.dart';

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
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


// add the app from file picker in here to match .exe
void main() {
  final winProc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
  EnumWindows(winProc, 0);

  for (var win in _list) {
    if (win.title != "") {
      stderr.write(
          "${win.title} | ${win.isActive} | hwnd: ${win.hWnd} | pID: ${win.processID} | ${win.exePath}\n");
    }
  }

  exit(0);
}
