// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables, avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'add_connection_screen.dart';
import 'category_page.dart';
import 'mqtt_config.dart';
import 'switch.dart';
import 'data_switches.dart';
import 'switch_bottomsheet.dart';
import 'switch_tile.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/firebase_options.dart';

import 'theme/theme_constants.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);
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

  int i = 0;

  final swRef = FirebaseDatabase.instance.ref("All/test");
  late StreamSubscription<DatabaseEvent> removes;
  late StreamSubscription<DatabaseEvent> added;
  late StreamSubscription<DatabaseEvent> updates;

  @override
  void initState() {
    setupMqttClient();
    init_switches();
    removes = swRef.onChildRemoved.listen(
      (event) {
        print(event.snapshot.key);
        init_switches();
      }, // OK GO ON delete switch with this id
    );
    added = swRef.onChildAdded.listen((event) {
      init_switches();
    });
    updates = swRef.onValue.listen((event) {
      init_switches();
    });

    super.initState();
  }

  @override
  void dispose() {
    removes.cancel();
    updates.cancel();
    added.cancel();
    MQobject.disconnect();
    super.dispose();
  }

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
    });
  }

  void updateState() {
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    List<SwitchTile> switchTiles = switches.map((p) => SwitchTile(switchItem: p)).toList();
    switchTiles.sort((a, b) => a.switchItem.id.compareTo(b.switchItem.id));
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
              itemBuilder: (context, index) => buildCards(switchTiles, index, context),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSwitchPage()),
          );
          // final switchData = {
          //   "id": "sw${s_id_generator()}",
          //   "name": "Switch ${s_id_generator()}",
          //   "room": "Room ${s_id_generator()}",
          //   "state": false,
          //   "icon": "assets/images/plug.png"
          // };
          // Map<String, Map> updates = {};
          // print(i);

          // updates['All/test/sw${s_id_generator()}'] = switchData;
          // FirebaseDatabase.instance.ref().update(updates);
          // i += 1;
          // final snapshot = await FirebaseDatabase.instance.ref('test').get();
          // var encoded = jsonEncode(snapshot.value); // String
          // var decoded = jsonDecode(encoded); // Map<String, dynamic>
          // print(encoded);
          // setState(() {
          //   decoded.forEach((v) => switches.add(Switch_.fromJson(v)));
          // });
        },
        elevation: 5.0,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottom_app_bar(),
    );
  }

  Card buildCards(List<SwitchTile> switchTiles, int index, BuildContext context) {
    return Card(
      elevation: 10,
      child: Column(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: (switchTiles[index].switchItem.icon.contains("assets/images"))
                ? Image.asset(
                    switchTiles[index].switchItem.icon,
                    fit: BoxFit.contain,
                    color: switchTiles[index].switchItem.icon.contains(".png")
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  )
                : Image.file(File(switchTiles[index].switchItem.icon)),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(switchTiles[index].switchItem.name),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        switchTiles[index].switchItem.state
                            ? switchTiles[index]
                                .switchItem
                                .turnOff(switchTiles[index].switchItem.name)
                            : switchTiles[index]
                                .switchItem
                                .turnOn(switchTiles[index].switchItem.name);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: switchTiles[index].switchItem.state
                          ? Colors.teal.shade800
                          : Colors.redAccent.shade700,
                      // fixedSize: const Size(50, 50),
                      elevation: 10,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: switchTiles[index].switchItem.state
                          ? const BorderSide(
                              color: Colors.white,
                              width: 4,
                            )
                          : const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                    ),
                    child: Text(switchTiles[index].switchItem.state ? "ON" : "OFF"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> init_switches() async {
    final snapshot = await FirebaseDatabase.instance.ref('All/test').get();
    var encoded = jsonEncode(snapshot.value); // String
    var decoded = jsonDecode(encoded); // Map<String, dynamic>

    setState(() {
      switches.clear();
      decoded.forEach((k, v) => switches.add(Switch_.fromJson(v)));
    });
  }

  int s_id_generator() {
    return i;
  }

  BottomAppBar bottom_app_bar() {
    return BottomAppBar(
      // color: Theme.of(context).colorScheme.primary,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.home),
            onPressed: () {
              updateTabSelection(0, "Home");
              print('13789\$&ali');
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.schedule),
            onPressed: () {
              updateTabSelection(1, "Timings");
              MQobject.disconnect();
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.settings),
            onPressed: () {
              //TODO : Design Settings PAGE
              updateTabSelection(2, "Settings");
            },
          ),
          IconButton(
            color: Colors.white,
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

  Widget Mydivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        indent: 60,
        thickness: 1.6,
        height: 0,
      ),
    );
  }

  Slidable slidableTiles(List<SwitchTile> switchTiles, int index) {
    void updateSwitch() {
      setState(() {});
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
                                switchTiles[index]
                                    .switchItem
                                    .deleteItem(switchTiles[index].switchItem.id);
                                // switches.removeWhere((item) => item.id == switchTiles[index].switchItem.id);
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
              pushBottomSheet(
                  context: context,
                  btmsheet: SwitchBottomSheet(
                    switchItem: switchTiles[index].switchItem,
                    callback: updateSwitch,
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

  Future<void> setupMqttClient() async {
    await MQobject.connect();
    // MQobject.subscribe("$_connectionName/${MQobject.registerTopic}", MqttQos.atLeastOnce);
  }
}

void pushBottomSheet({required BuildContext context, required Widget btmsheet}) {
  showModalBottomSheet(
    isScrollControlled: true,
    clipBehavior: Clip.antiAlias,
    elevation: 50.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) => btmsheet,
  );
}

List<String> collections = ["Room 1", "Room 2", "Room 3", "Room 4", "Room 5"];

List<String> images = [
  "assets/images/plug.png",
  "assets/images/air-conditioner.png",
  "assets/images/electric-stove.png",
  "assets/images/laundry.png",
  "assets/images/loudspeaker.png",
  "assets/images/microwave.png",
  "assets/images/mixer-blender.png",
  "assets/images/3248571.png",
  "assets/images/phone-charger.png",
  "assets/images/rice-cooker.png",
  "assets/images/toaster.png",
  // "assets/images/vacuum-cleaner.png ",
  "assets/images/washing-machine.png",
  "assets/images/water-dispenser.png",
  "assets/images/water-pump.png",
  "assets/images/wifi-router.png",
  "assets/images/ex.jpg",
];
List<String> inAppImages = [];
