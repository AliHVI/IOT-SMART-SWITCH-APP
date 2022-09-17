import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'main.dart';
import 'switch.dart';

class SwitchBottomSheet extends StatefulWidget {
  const SwitchBottomSheet({Key? key, required this.switchItem, required this.callback()})
      : super(key: key);
  final Switch_ switchItem;
  final Function callback;
  @override
  State<SwitchBottomSheet> createState() => _SwitchBottomSheetState();
}

class _SwitchBottomSheetState extends State<SwitchBottomSheet> {
  Switch_ get switchItem => widget.switchItem;

  final _controller = TextEditingController();
  final dialogController = TextEditingController();

  String? selectedImg;

  String? menuSelecteditem;

  String? imagePath;
  @override
  void initState() {
    _controller.text = switchItem.name;
    selectedImg = switchItem.icon;
    menuSelecteditem = switchItem.room;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> avatars = buildAvatars();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Divider(
                color: Colors.grey.shade600,
                thickness: 3.0,
                endIndent: MediaQuery.of(context).size.width * 0.35,
                indent: MediaQuery.of(context).size.width * 0.35,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      switchItem.name,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                        icon: const Icon(Icons.close))
                  ],
                ),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: _controller.text.isNotEmpty
                        ? const BorderSide(color: Colors.orange)
                        : const BorderSide(color: Colors.red),
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    gapPadding: 5.0,
                  ),
                  labelText: 'Enter Name',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    switchItem.rename(switchItem.id, _controller.text);
                    switchItem.updateRoom(switchItem.id, menuSelecteditem.toString());
                    switchItem.updateIcon(switchItem.id, selectedImg!);
                    //_controller.text.isNotEmpty ? widget.callback(_controller.text) : null;

                    Navigator.pop(context);
                  },
                  child: const Text('Save')),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: DropdownButtonFormField(
                    dropdownColor: Colors.yellow.shade100,
                    elevation: 20,
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.35,
                    decoration: const InputDecoration(
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
                            .toList() +
                        [
                          DropdownMenuItem(
                            value: null,
                            child: Column(
                              children: [
                                const Divider(
                                  color: Colors.black,
                                  thickness: 3.0,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.add),
                                    TextButton(
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                                child: SizedBox(
                                                    width: double.infinity,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Text("Enter new Collection name :"),
                                                        TextField(
                                                          controller: dialogController,
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: (() {
                                                              setState(() {
                                                                collections
                                                                    .add(dialogController.text);
                                                              });
                                                              Navigator.pop(context);
                                                            }),
                                                            child: const Text('submit'))
                                                      ],
                                                    )),
                                              )),
                                      child: const Text('Add New Room'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                    onChanged: (item) => setState(() {
                          if (item != "Add new Room") {
                            menuSelecteditem = item.toString();
                            // switchItem.room = item.toString();
                            //switchItem.updateRoom(switchItem.id, item.toString());
                          }
                        })),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Scrollbar(
                    thickness: 6,
                    thumbVisibility: true,
                    interactive: true,
                    radius: const Radius.circular(25.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.2,
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

  void setSelectedImageUrl(String url) {
    setState(() {
      // switchItem.icon = url; "1"
      //switchItem.updateIcon(switchItem.id, url);  "2"
      selectedImg = url;
    });
  }

  void pickImage() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 50);
    if (file != null) {
      String imagePath = file.path;
      setState(() {
        inAppImages.add(imagePath);
      });
    }
  }

  List<Widget> buildAvatars() {
    List<Widget> avatars = images
            .map((p) => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => setSelectedImageUrl(p),
                      child: CircleAvatar(
                          //backgroundImage: AssetImage(p),
                          backgroundColor: selectedImg == p ? Colors.yellow : Colors.transparent,
                          radius: 25,
                          child: Image.asset(
                            p,
                            width: 40,
                          )),
                    ),
                  ),
                ))
            .toList() +
        inAppImages
            .map((p) => Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => setSelectedImageUrl(p),
                      child: CircleAvatar(
                          //backgroundImage: AssetImage(p),
                          backgroundColor: selectedImg == p ? Colors.yellow : Colors.transparent,
                          radius: 25,
                          child: Image.file(
                            File(p),
                            width: 40,
                          )),
                    ),
                  ),
                ))
            .toList() +
        [
          Container(
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.add),
              color: Colors.green.shade300,
              tooltip: "Pick from Gallery",
              onPressed: () {
                pickImage();
              },
            ),
          ),
        ];
    return avatars;
  }
}
