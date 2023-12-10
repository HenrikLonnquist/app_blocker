import 'package:flutter/material.dart';

class CustomGridView extends StatefulWidget {
  const CustomGridView({
    super.key,
    this.programNames,
    required this.itemCount,
    required this.onSelectedChanged,
  });

  final int itemCount;
  final List? programNames;
  // maybe together the function to send overlayentries as well
  final void Function(Map<int, String>, Map<int, OverlayEntry>) onSelectedChanged;

  @override
  State<CustomGridView> createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  final Map<int, OverlayEntry> _overlayEntries = {};
  final link = LayerLink();
  
  Map<int, String> selectedProgramList = {};
  bool selectedProgram = false;


  void showSelectedProgramOverlay(int index){

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset tapPosition = renderBox.localToGlobal(Offset.zero);

    
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: tapPosition.dy + (index ~/ 4) * 60.0, 
          left: tapPosition.dx + (index % 4) * 81.1, 
          child: const Material(
            color: Colors.transparent,
            child: Icon(
              Icons.check_box,
              size: 16,
              color: Color.fromRGBO(217, 217, 217, 1),
        
            ),
          ),
        );
      }
    );
    
    _overlayEntries[index] = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
    widget.onSelectedChanged(selectedProgramList, _overlayEntries);
  }

  // TODO: Maybe make an animation removal of overlayentry?
  void removeOverlay(int index) {
    final OverlayEntry? overlayEntry = _overlayEntries[index];
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry.dispose();
      _overlayEntries.remove(index);
      widget.onSelectedChanged(selectedProgramList, _overlayEntries);
    }
  }
  
  void removeAllOverlayEntries(){
    for (var entry in _overlayEntries.values) {
      entry.remove();
      entry.dispose();
    }

    _overlayEntries.clear();
  }

  @override
  void dispose() {
    super.dispose();
    removeAllOverlayEntries();
  }


  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 80,
        mainAxisExtent: 50,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: widget.itemCount,
      // For testing....>
      // itemCount: 20,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTapDown: (details){
            setState(() {
              if (_overlayEntries.containsKey(index)) {
                
                selectedProgramList.remove(index);
                removeOverlay(index);
              } else {
                selectedProgramList[index] = widget.programNames![index];
                showSelectedProgramOverlay(index);
              }});
          },
          //!Container only here for visiblity sake
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(217, 217, 217, 1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      width: 1,
                    )
                  ),
                  // TODO: switch programs icon if possible
                  child: const Icon(
                    Icons.emergency,
                    size: 26,
                    color: Color.fromRGBO(217, 217, 217, 1),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  // TODO: get the program actual name: It's not called CalculatorApp, right?
                  child: Text(
                    widget.programNames![index].split(".")[0],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color.fromRGBO(217, 217, 217, 1),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}