// ignore_for_file: unused_local_variable, non_constant_identifier_names, constant_identifier_names, avoid_print
import "dart:ffi";
import "dart:io";
// import "logic.dart";
import "dart:isolate";

import "package:ffi/ffi.dart";
import "package:win32/win32.dart";

final _user32 = DynamicLibrary.open('user32.dll');

typedef WINEVENTPROC = Void Function(
    IntPtr hWinEventHook,
    Uint32 event,
    IntPtr hwnd,
    Long idObject,
    Long idChild,
    Uint32 idEventThread,
    Uint32 dwmsEventTime);

int SetWinEventHook(
        int eventMin,
        int eventMax,
        Pointer hmodWinEventProc,
        Pointer<NativeFunction<WINEVENTPROC>> pfnWinEventProc,
        int idProcess,
        int idThread,
        int dwFlags) =>
    _SetWinEventHook(eventMin, eventMax, hmodWinEventProc, pfnWinEventProc,
        idProcess, idThread, dwFlags);

final _SetWinEventHook = _user32.lookupFunction<
    IntPtr Function(
        Uint32 eventMin,
        Uint32 eventMax,
        Pointer hmodWinEventProc,
        Pointer<NativeFunction<WINEVENTPROC>> pfnWinEVentProc,
        Uint32 idProcess,
        Uint32 idThread,
        Uint32 dwFlags),
    int Function(
        int eventMin,
        int eventMax,
        Pointer hmodWinEventProc,
        Pointer<NativeFunction<WINEVENTPROC>> pfnWinEVentProc,
        int idProcess,
        int idThread,
        int dwFlags)>('SetWinEventHook');

void _winEventCallback(int hWinEventHook, int event, int hwnd, int idObject,
    int idChild, int idEventThread, int dwmsEventTime) {
  if (event == 3) {
    UnhookWindowsHookEx(hWinEventHook);
    print('Window event changed. Event: $event, HWND: $hwnd');
    //! problem with the await async functionality, dont know why it wont continue after await readjsonfile 
    //! i think the problem is with the getmessage function, in that it will block when waiting for a message.
    // watchingActiveWindow(hwnd);
  }
}

void eventMonitoring(SendPort sendPort) {
  // const EVENT_SYSTEM_FOREGROUND = 0x0003;
  const WINEVENT_OUTOFCONTEXT = 0;
  const WINEVENT_SKIPOWNPROCESS = 2;

  var hook = SetWinEventHook(
      0x0003,
      0x0003,
      Pointer.fromAddress(0),
      Pointer.fromFunction<WINEVENTPROC>(_winEventCallback),
      0,
      0,
      WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS);

  if (hook == 0) {
    print("Failed to hook");
    return;
  }

  final msg = calloc<MSG>();

  while (GetMessage(msg, 0, 0, 0) != 0) {
    sleep(const Duration(milliseconds: 100));
  }
  free(msg);
  sendPort.send("Event monitoring isolate has started.");
}

void startEventMonitoringIsolate() async {
  // isolate event monitoring
  final receivePort = ReceivePort();

  // Create and spawn an isolate
  final eventMonitoringIsolateSendPort = await Isolate.spawn(
    eventMonitoring,
    receivePort.sendPort,
  );

  // Listen for messages from the event monitoring isolate
  receivePort.listen((message) {
    print('Received message from isolate: $message');
  });
}
