import 'package:flutter/material.dart';
import 'package:uitest/main.dart';
import 'package:uitest/switchTile.dart';
import 'model/model.dart';

class SwitchBottomSheet extends StatefulWidget {
  const SwitchBottomSheet({Key? key, required this.switchItem, required this.callback(String name)})
      : super(key: key);
  final Switch_ switchItem;
  final Function callback;
  @override
  State<SwitchBottomSheet> createState() => _SwitchBottomSheetState();
}

class _SwitchBottomSheetState extends State<SwitchBottomSheet> {
  Switch_ get switchItem => widget.switchItem;
  final _controller = TextEditingController();
  String? selectedImg;
  String menuSelecteditem = collections.first;
  @override
  void initState() {
    _controller.text = switchItem.name;
    selectedImg = "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSwitchName(String name) {
    setState(() {
      switchItem.name = name;
    });
  }

  void setSelectedImageUrl(String url) {
    setState(() {
      switchItem.icon = url;
      selectedImg = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> avatars = images
        .map((p) => Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  onTap: () => setSelectedImageUrl(p),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(p),
                    backgroundColor: selectedImg == p ? Colors.yellow : Colors.transparent,
                    radius: 25,
                  ),
                ),
              ),
            ))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: ListView(
            controller: scrollController,
            // mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                color: Colors.grey.shade600,
                thickness: 3.0,
                endIndent: MediaQuery.of(context).size.width * 0.35,
                indent: MediaQuery.of(context).size.width * 0.35,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  switchItem.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              TextFormField(
                controller: _controller,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: _controller.text.isNotEmpty
                        ? BorderSide(color: Colors.orange)
                        : BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    gapPadding: 5.0,
                  ),
                  labelText: 'Enter Name',
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    switchItem.rename(_controller.text);
                    _controller.text.isNotEmpty ? widget.callback(_controller.text) : null;
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Save')),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: DropdownButtonFormField(
                    elevation: 20,
                    
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        gapPadding: 5.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        gapPadding: 5.0,
                      ),
                    ),
                    value: menuSelecteditem,
                    items: collections
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList() + [
                          DropdownMenuItem(
                            value:null,
                            child: Column(
                              children: [
                                const Divider(
                                  color: Colors.black,
                                  thickness: 3.0,
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.add),
                                    Text('Add New Room'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                    onChanged: (item) => setState(() {
                          menuSelecteditem = item.toString();
                          switchItem.room = item.toString();
                        })),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration:const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar(
                    thickness: 6,
                    thumbVisibility: true,
                    interactive: true,
                    radius:const Radius.circular(25.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                      children: avatars,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}