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
  final processID;

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

// ignore: unused_element
int _enumChildWindowsProc(int hWnd, int lParam) {
  // final child = FindWindowEx(hWnd, 0, nullptr, nullptr);
  final test2 = GetWindow(hWnd, 5);

  // stderr.write("did something happen here? $child ");
  stderr.write("did something happen here? $test2 ");

  return TRUE;
}



// Getting children of a window
// _enumChildWindowsProc(hWnd, 0);

// PROCESS ID OF THE WINDOW FUNCTION
/* final pID = calloc<Uint32>(1);
GetWindowThreadProcessId(hWnd, pID); 
// final int test = pId.value;
// stderr.write("Parent: ${GetParent(hWnd)} \n");
// Can not find the right process ID for MS Todo, which makes me think that it is not the only one that might be incorrect.
stderr.write("Process ID: ${pID.value} \n\n"); 
free(pID);
*/



int _enumWindowsProc(int hWnd, int lParam) {
  if (IsWindowVisible(hWnd) == TRUE) {
    final length = GetWindowTextLength(hWnd);
    final buffer = wsalloc(length + 1);

    GetWindowText(hWnd, buffer, length + 1);

    bool isActive = GetForegroundWindow() == hWnd;
    final String title = buffer.toDartString();
    _list.add(Window(
        title: title, isActive: isActive, hWnd: hWnd, processID: Null));
    free(buffer);
  }
  return TRUE;
}

void main() {
  final winProc = Pointer.fromFunction<EnumWindowsProc>(_enumWindowsProc, 0);
  EnumWindows(winProc, 0);

  for (var win in _list) {
    if (win.title != "") {
      stderr.write(
          "${win.title} | ${win.isActive} | ${win.hWnd} | ${win.exePath} | ${win.processID}\n");
    }
    // stderr.write("${win.title} | ${win.isActive} | ${win.hWnd} | ${win.exePath}\n");
  }

  exit(0);
}
