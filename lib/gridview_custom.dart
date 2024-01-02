import 'dart:typed_data';
import "package:image/image.dart" as img;
import 'package:flutter/material.dart';

class CustomGridView extends StatefulWidget {
  const CustomGridView({
    super.key,
    this.programNames,
    required this.itemCount,
    this.onSelectedChanged,
  });

  final int itemCount;
  final List? programNames;
  // maybe together the function to send overlayentries as well
  final void Function(Map<int, dynamic>)? onSelectedChanged;

  @override
  State<CustomGridView> createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  Map<int, dynamic> selectedProgramList = {};
  bool selectedProgram = false;
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          // mainAxisExtent: 50,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1.4,
        ),
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return InkWell(
            onTapDown: (details){

              setState(() {
                if(selectedProgramList.containsKey(index)){
                  selectedProgramList.remove(index);
                  widget.onSelectedChanged!(selectedProgramList);
                } else {
                  selectedProgramList[index] = widget.programNames![index];
                  widget.onSelectedChanged!(selectedProgramList);
                }
              });
              
            },
            child: Container(
              decoration: BoxDecoration(
                color: selectedProgramList[index] == null ? Colors.transparent : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    child: widget.programNames![index]["icon"].runtimeType == String ?
                    Image(image: AssetImage(widget.programNames![index]["icon"]),) :
                    Image.memory(Uint8List.fromList(img.encodePng(widget.programNames![index]["icon"])))
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    // TODO: LATER: get the program actual name: It's not called CalculatorApp, right?
                    // I think its fine, not a big problem. You still know what program it is. 
                    // Yes, look into it later.
                    child: Text(
                      widget.programNames![index]["name"].split(".")[0],
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
      ),
    );
  }
}