// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uitest/switchTile.dart';
import 'package:uitest/switch_bottomsheet.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uitest/add_connection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool clickedCentreFAB = false;
  int selectedIndex = 0;
  String text = "Home";
  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
      text = buttonText;
    });
  }

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SwitchTile> switchTiles = switches.map((p) => SwitchTile(switchItem: p)).toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.next_plan_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecondPage(
                          callback: updateState,
                        )),
              );
            },
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: SlidableAutoCloseBehavior(
          child: ListView.separated(
            itemCount: switchTiles.length,
            itemBuilder: (_, index) => slidableTiles(switchTiles, index),
            separatorBuilder: (context, index) => const Divider(
              indent: 60,
              thickness: 1.6,
              height: 0,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              clickedCentreFAB = !clickedCentreFAB;
            });
          },
          elevation: 5.0,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: bottom_app_bar(),
      ),
    );
  }

  BottomAppBar bottom_app_bar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              updateTabSelection(0, "Home");
            },
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              updateTabSelection(3, "Timings");
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              updateTabSelection(3, "Settings");
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              updateTabSelection(3, "microphone");
            },
          ),
        ],
      ),
    );
  }

  Slidable slidableTiles(List<SwitchTile> switchTiles, int index) {
    void updateSwitchName(String name) {
      setState(() {
        switchTiles[index].switchItem.name = name;
      });
    }

    return Slidable(
      key: Key(
          switchTiles[index].switchItem.id.toString()), // for eneabling the dismiss functionality
      groupTag: Object, // used for closeBehavior
      startActionPane: ActionPane(
        dismissible: DismissiblePane(onDismissed: () {
          setState(() {
            switches.removeWhere((item) => item.id == switchTiles[index].switchItem.id);
            // switches.removeAt(index);
          });
        }),
        motion: const StretchMotion(),
        extentRatio: 0.50,
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              setState(() {
                switches.removeWhere((item) => item.id == switchTiles[index].switchItem.id);
                // switches.removeAt(index);
              });
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            autoClose: true,
          ),
          SlidableAction(
            onPressed: (context) {
              // _panelController.open();
              _pushBottomSheet(
                  context: context,
                  btmsheet: SwitchBottomSheet(
                    switchItem: switchTiles[index].switchItem,
                    callback: updateSwitchName,
                  ));
              setState(() {});
            },
            backgroundColor: Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: switchTiles[index],
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.callback}) : super(key: key);
  final Function callback;
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  void updateSwitchName(String name) {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              widget.callback();
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Second Page",
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: SlidableAutoCloseBehavior(
          child: ListView.builder(
              itemBuilder: ((context, index) {
                var switches2 = switches.where((s) => s.room == collections[index]).toList();
                var index2 = 0;
                List<SwitchTile> switchTiles2 =
                    switches2.map((p) => SwitchTile(switchItem: p)).toList();
                if (switches2.isEmpty) {
                  return Container();
                }
                return ExpansionTile(
                  title: Text(collections[index]),
                  children: 
                  switches2.isNotEmpty
                      ? switches2.map((s) {
                          index2++;
                          return Slidable(
                              key: Key(s.id.toString()),
                              groupTag: Object,
                              startActionPane: ActionPane(
                                dismissible: DismissiblePane(onDismissed: () {
                                  setState(() {
                                    switches.removeWhere(
                                        (item) => item.id == switchTiles2[index2].switchItem.id);
                                  });
                                }),
                                motion: const StretchMotion(),
                                extentRatio: 0.50,
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) {
                                      setState(() {
                                        switches.removeAt(index2);
                                      });
                                    },
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    autoClose: true,
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      // _panelController.open();
                                      _pushBottomSheet(
                                          context: context,
                                          btmsheet: SwitchBottomSheet(
                                            switchItem: s,
                                            callback: updateSwitchName,
                                          ));
                                      setState(() {});
                                    },
                                    backgroundColor: Color(0xFF21B7CA),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                ],
                              ),
                              child: switchTiles2[index2]);
                        }).toList()
                      : [Text("No Switches in this room")],
                );
              }),
              itemCount: collections.length),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // open new page to add new switch with name and room page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSwitchPage()),
            );
          },
          elevation: 5.0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

void doNothing(BuildContext context) {}

void _pushBottomSheet({required BuildContext context, required Widget btmsheet}) {
  //isbtmshtOpened = false;
  showModalBottomSheet(
    isScrollControlled: true,
    clipBehavior: Clip.none,
    elevation: 50.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) => btmsheet,
  );
}

class SwitchList with ChangeNotifier {
  List<Switch_> itemsInList = [];
  void addSwitch(Switch_ switchItem) {
    itemsInList.add(switchItem);
    notifyListeners();
  }

  void removeSwitch(Switch_ switchItem) {
    itemsInList.remove(switchItem);
    notifyListeners();
  }
}

List<Switch_> switches = [
  Switch_(
    id: 1,
    name: "Switch 1",
    room: "Room 1",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 2,
    name: "Switch 2",
    room: "Room 2",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 3,
    name: "Switch 3",
    room: "Room 2",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 4,
    name: "Switch 4",
    room: "Room 4",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 5,
    name: "Switch 5",
    room: "Room 4",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 6,
    name: "Switch 6",
    room: "Room 4",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 7,
    name: "Switch 7",
    room: "Room 1",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 8,
    name: "Switch 8",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 9,
    name: "Switch 9",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 10,
    name: "Switch 10",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 11,
    name: "Switch 11",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 12,
    name: "Switch 12",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 13,
    name: "Switch 13",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 14,
    name: "Switch 14",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
  Switch_(
    id: 15,
    name: "Switch 15",
    room: "Room 5",
    state: false,
    icon: "assets/images/plug.png",
  ),
];

List<String> collections = ["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"];

List<String> images = [
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
  "assets/images/plug.png",
];
