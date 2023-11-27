import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomOverlay extends StatefulWidget {
  final double containerWidth;
  final double containerHeight;
  // final Widget child;

  
  const CustomOverlay({
    super.key,
    this.containerWidth = 100,
    this.containerHeight = 100,
    
  });

  @override
  // ignore: library_private_types_in_public_api
  CustomOverlayState createState() => CustomOverlayState();
}

class CustomOverlayState extends State<CustomOverlay> {
  OverlayEntry? overlayEntry;
  List<String> dropList = ["days", "weeks", "months", "years"];
  List<String> dropdownList = ["A", "B", "Custom",];
  String? dropValue;
  

  // ignore: unused_element
  void createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    Rect rect = offset & size;
    double verticalOffset = 5.0;

    removeOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: rect.bottom + verticalOffset,
        left: rect.left,
        child: Container(
          width: rect.width + widget.containerWidth,
          height: rect.height + widget.containerHeight,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: const Color.fromRGBO(9, 80, 113, 1)),
          child: Column(
            children: [
              const Text("Repeat every ...",
                  style: TextStyle(
                    fontSize: 14,
                  )),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 40,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Material(
                        borderRadius: BorderRadius.circular(8.0),
                        child: TextFormField(
                          initialValue: "1",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("days"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      removeOverlay();
                    },
                    child: const Text("Cancel",
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      //call the "database" to save and display the new info
                      //to the Triggered widget -> DropdownButton2{Custom}
                      setState(() {
                        dropValue = "Custom"; //TODO: change this later to the custom values chosen by the user
                      });
                      removeOverlay();
                    },
                    child: const Text("Save",
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
    Overlay.of(context).insert(overlayEntry!);
  }


  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlay();
  }

  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: const Text(
          "Repeat",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        value: dropValue,
        items: dropdownList.map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value)
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            if (value == "Custom") {
              createOverlayEntry();
            } else {
              removeOverlay();
              dropValue = value!;
            }
          });
        },
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
          ),
          iconSize: 20,
          iconEnabledColor: Colors.white,
      
        ),
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: const Color.fromRGBO(9, 80, 113, 1),
          )
        ),
        dropdownStyleData: DropdownStyleData(
          offset: const Offset(0, 100),
          maxHeight: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: const Color.fromRGBO(9, 80, 113, 1),
          )
        ),
      
      ),
    );
  }

  
}
