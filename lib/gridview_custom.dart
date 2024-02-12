import 'package:flutter/material.dart';

class CustomGridView extends StatefulWidget {
  const CustomGridView({
    super.key,
    this.programNames,
    this.itemCount = 0,
    required this.onSelectedChanged,
    this.currentTab = 0,
    this.selectState,
    this.checkForAllPrograms = false,
    this.noIcon = false,
    this.child,
  });

  final Widget? child;

  final bool noIcon;

  final bool? selectState;

  final int currentTab;

  final int itemCount;

  final List? programNames;

  // TODO: need a better name
  final bool checkForAllPrograms;
  
  final void Function(Map<int, dynamic>)? onSelectedChanged;
  
  


  @override
  State<CustomGridView> createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  int currTab = 0;

  Map<int, dynamic> selectedProgramList = {};
  

  void selectAllPrograms(){

    selectedProgramList.clear();

    for (var i = 0; i < widget.programNames!.length; i++) {
      selectedProgramList[i] = widget.programNames![i];
    }

  }

  @override
  void dispose() {
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    
    if (currTab != widget.currentTab){
      currTab = widget.currentTab;
      selectedProgramList.clear();
    }

    
    if (widget.selectState == true) {   // Select All
      
      selectAllPrograms();
      
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.onSelectedChanged!(selectedProgramList);
      });

    } else if (widget.selectState == false) {   // Deselect All
      
      selectedProgramList.clear();
      
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.onSelectedChanged!(selectedProgramList);
      });

    }

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
          
          return widget.child ?? InkWell(
            onTap: widget.programNames![0]["name"] == "allPrograms.exe" 
            && widget.checkForAllPrograms && widget.programNames![index]["name"] != "allPrograms.exe"
            ?
            null :
            (){

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
            child: Stack(
              children: [
                
                Container(
                  //widget.programNames![index]["name"] == "allPrograms.exe"
                  decoration: BoxDecoration(
                    color: selectedProgramList[index] == null ?
                    Colors.transparent :
                    Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.noIcon == false)
                      Container(
                        child: widget.programNames![index]["icon"].runtimeType == String ?
                        Image(image: AssetImage(widget.programNames![index]["icon"])) :
                        widget.programNames![index]["icon"]
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        // TODO: LATER: get the program actual name: It's not called CalculatorApp, right?
                        // I think its fine, not a big problem. You still know what program it is. 
                        // Yes, I can look into it later.
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
                if(widget.programNames![0]["name"] == "allPrograms.exe" 
                && widget.programNames![index]["name"] != "allPrograms.exe"
                && widget.checkForAllPrograms)Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ]
            ),
          );
        },
      ),
    );
  }
}