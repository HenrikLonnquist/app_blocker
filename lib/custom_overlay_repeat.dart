import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';


class CustomOverlayPortal extends StatefulWidget {
  const CustomOverlayPortal({
    super.key,
    this.width = 200,
    this.height = 130,
  });

  final double? width;
  final double? height;


  @override
  // ignore: library_private_types_in_public_api
  CustomOverlayPortalState createState() => CustomOverlayPortalState();
}

class CustomOverlayPortalState extends State<CustomOverlayPortal> {
  final OverlayPortalController tooltipController = OverlayPortalController();
  final _link = LayerLink();

  List<String> repeatList = ["days", "weeks", "months", "years"];
  String? repeatValue;

  List<String> dropdownList = ["Daily", "Weekdays", "Weekly", "Monthly", "Yearly", "Custom",];
  String? dropValue;


  void toggleOverlayPortal() {

    tooltipController.toggle();

  }


  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: tooltipController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color.fromRGBO(9, 80, 113, 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("  Repeat every ...",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
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
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 8,
                            child: Material(
                              borderRadius: BorderRadius.circular(8.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  items: repeatList.map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    repeatList[0],
                                    style: const TextStyle(
                                      fontSize: 15,
                                    )
                                  ),
                                  value: repeatValue,
                                  onChanged: (String? value) {
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextButton( // TODO: fix the borderRadius
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white, 
                            ),
                            onPressed: toggleOverlayPortal,
                            child: const Text("Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                )),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 5,
                          child: TextButton(
                            style: TextButton.styleFrom(backgroundColor: Colors.white),
                            onPressed: () {
                              // TODO: call the "database" to save and display the new info
                              //to the Triggered widget -> DropdownButton2{Custom}
                              setState(() {
                                dropValue = "Custom"; 
                                toggleOverlayPortal();
                              });
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.black,
                              )
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          );
        },
        child: DropdownButtonHideUnderline(
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
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                if (value == "Custom") {
                  toggleOverlayPortal();
                } else {
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
              offset: const Offset(0, 150),
              maxHeight: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: const Color.fromRGBO(9, 80, 113, 1),
              )
            ),
          ),
        )
      ),
    );
  }

  
}