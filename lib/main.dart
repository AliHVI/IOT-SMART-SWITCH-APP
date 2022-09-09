// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables, avoid_print, library_private_types_in_public_api

import 'category_page.dart';
import 'models/switch.dart';
import 'models/data_switches.dart';
import 'switch_bottomsheet.dart';
import 'switch_tile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/theme_constants.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: buildReplyLightTheme(context),
      darkTheme: buildReplyDarkTheme(context),
      themeMode: _themeManager.themeMode,
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool clickedCentreFAB = false;
  int selectedIndex = 0;

  String text = "Home";

  bool isDark = false;
  bool gridview = false;

  late int i;

  final swRef = FirebaseDatabase.instance.ref("/test");

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
    });
  }

  void updateState() {
    setState(() {});
  }

  @override
  void initState() {
    swRef.onChildRemoved.listen((event) {
      init_switches();
    });
    init_switches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SwitchTile> switchTiles = switches.map((p) => SwitchTile(switchItem: p)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.next_plan_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CategoryPage(
                        callback: updateState,
                      )),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  gridview = !gridview;
                });
              },
              icon: !gridview ? Icon(Icons.grid_view_rounded) : Icon(Icons.view_list_rounded)),
          // Switch(
          //     value: _themeManager.themeMode == ThemeMode.dark,
          //     onChanged: (newValue) {
          //       _themeManager.toggleTheme(newValue);
          //     })
          IconButton(
              onPressed: (() =>
                  _themeManager.toggleTheme(_themeManager.themeMode == ThemeMode.dark)),
              icon: _themeManager.themeMode == ThemeMode.dark
                  ? Icon(Icons.wb_sunny)
                  : Icon(Icons.nightlight_round_sharp))
        ],
      ),
      body: !gridview
          ? SlidableAutoCloseBehavior(
              child: ListView.separated(
                  itemCount: switchTiles.length,
                  itemBuilder: (_, index) => slidableTiles(switchTiles, index),
                  separatorBuilder: (context, index) => Mydivider()),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: switches.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: switchTiles[index],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final snapshot = await FirebaseDatabase.instance.ref('All/test').get();
          var encoded = jsonEncode(snapshot.value); // String
          var decoded = jsonDecode(encoded); // Map<String, dynamic>
          setState(() {
            decoded.forEach((k, v) => switches.add(Switch_.fromJson(v)));
          });
        },
        elevation: 5.0,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottom_app_bar(),
    );
  }

  Future<List<Switch_>> init_switches() async {
    final snapshot = await FirebaseDatabase.instance.ref('All/test').get();
    var encoded = jsonEncode(snapshot.value); // String
    var decoded = jsonDecode(encoded); // Map<String, dynamic>
    setState(() {
      decoded.forEach((k, v) => switches.add(Switch_.fromJson(v)));
    });
    return switches;
  }

  void s_id_generator() {
    i += 1;
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
              updateTabSelection(1, "Timings");
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              //TODO : Design Settings PAGE
              updateTabSelection(2, "Settings");
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              //TODO : open dialog box for recieve voice and desired animation
              updateTabSelection(3, "microphone");
            },
          ),
        ],
      ),
    );
  }

  Divider Mydivider() {
    return Divider(
      indent: 60,
      thickness: 1.6,
      height: 0,
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
        // dismissible: DismissiblePane(onDismissed: () {
        //   setState(() {
        //     switches.removeWhere((item) => item.id == switchTiles[index].switchItem.id);
        //     // switches.removeAt(index);
        //   });
        // }),
        motion: const StretchMotion(),
        extentRatio: 0.50,
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              // TODO: complete ui task for this
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("WARNING"),
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(switchTiles[index].switchItem.name)),
                      actions: [
                        TextButton(
                          onPressed: (() => Navigator.pop(context)),
                          child: Text("CANCEL"),
                        ),
                        ElevatedButton(
                            onPressed: (() {
                              setState(() { 
                                // switchTiles[index]
                                //     .switchItem
                                //     .deleteItem(switchTiles[index].switchItem.id);
                                DatabaseReference ref =
                                    FirebaseDatabase.instance.ref('All/test/-NAoPpF8QFZrbxWSHenv');
                                ref.remove();
                                //switches.removeWhere((item) => item.id == switchTiles[index].switchItem.id);
                                // switches.removeAt(index);
                              });
                              Navigator.pop(context);
                            }),
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: Text("DELETE"))
                      ],
                    );
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
              pushBottomSheet(
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

void doNothing(BuildContext context) {}

void pushBottomSheet({required BuildContext context, required Widget btmsheet}) {
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
