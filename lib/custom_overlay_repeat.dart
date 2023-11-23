import 'package:flutter/material.dart';

class CustomOverlay extends StatefulWidget {

  const CustomOverlay({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomOverlayState createState() => _CustomOverlayState();
}

class _CustomOverlayState extends State<CustomOverlay> {
  late OverlayEntry overlayEntry;

  // ignore: unused_element
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Focus(child: ),
            Positioned.fromRect(
              rect: _getRect(),
              child: Container(),
            ),
          ],
        );
      }
    );
    // Overlay.of(context).insert(overlayEntry);
  }
  
  Rect _getRect() {
    final TextDirection? textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = EdgeInsets.zero;

    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;

    return menuMargin.resolve(textDirection).inflateRect(itemRect);
  }

  void removeOverlay() {
    overlayEntry.remove();
    overlayEntry.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }

}

