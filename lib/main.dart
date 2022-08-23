// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uitest/esptouch.dart';
import 'package:uitest/switchTile.dart';
import 'package:uitest/switch_bottomsheet.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
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
                MaterialPageRoute(builder: (context) => SecondPage(callback: updateState,)),
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
            switchTiles.removeAt(index);
            switches.removeAt(index);
          });
        }),
        motion: const StretchMotion(),
        extentRatio: 0.50,
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              setState(() {
                switchTiles.removeAt(index);
                switches.removeAt(index);
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
                if (switches2.isEmpty) {
                  return Container();
                }
                return ExpansionTile(
                  title: Text(collections[index]),
                  children: switches2.isNotEmpty
                      ? switches2
                          .map((s) => Slidable(
                              key: Key(s.id.toString()),
                              groupTag: Object,
                              startActionPane: ActionPane(
                                dismissible: DismissiblePane(onDismissed: () {
                                  setState(() {
                                    switches.removeAt(index);
                                  });
                                }),
                                motion: const StretchMotion(),
                                extentRatio: 0.50,
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) {
                                      setState(() {
                                        switches.removeAt(index);
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
                              child: SwitchTile(switchItem: s)))
                          .toList()
                      : [Text("No Switches in this room")],
                );
              }),
              // separatorBuilder: (context, index) => const Divider(
              //       indent: 60,
              //       thickness: 1.6,
              //       height: 0,
              //     ),
              itemCount: collections.length),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // open new page to add new switch with name and room page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Wemos()),
            );
          },
          elevation: 5.0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// class AddSwitchPage extends StatefulWidget {
//   const AddSwitchPage({Key? key}) : super(key: key);

//   @override
//   State<AddSwitchPage> createState() => _AddSwitchPageState();
// }

// class _AddSwitchPageState extends State<AddSwitchPage> {
//   String _connectionName = "";
//   final _networkInfo = NetworkInfo();
//   @override
//   void initState() {
//     super.initState();
//     _initNetworkInfo();
//   }

//   Future<String> _initNetworkInfo() async {
//     String? wifiName, wifiBSSID, wifiIPv4, wifiIPv6, wifiGatewayIP, wifiBroadcast, wifiSubmask;

//     try {
//       if (!kIsWeb && Platform.isIOS) {
//         var status = await _networkInfo.getLocationServiceAuthorization();
//         if (status == LocationAuthorizationStatus.notDetermined) {
//           status = await _networkInfo.requestLocationServiceAuthorization();
//         }
//         if (status == LocationAuthorizationStatus.authorizedAlways ||
//             status == LocationAuthorizationStatus.authorizedWhenInUse) {
//           wifiName = await _networkInfo.getWifiName();
//         } else {
//           wifiName = await _networkInfo.getWifiName();
//         }
//       } else {
//         wifiName = await _networkInfo.getWifiName();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi Name', error: e);
//       wifiName = 'Failed to get Wifi Name';
//     }

//     try {
//       if (!kIsWeb && Platform.isIOS) {
//         var status = await _networkInfo.getLocationServiceAuthorization();
//         if (status == LocationAuthorizationStatus.notDetermined) {
//           status = await _networkInfo.requestLocationServiceAuthorization();
//         }
//         if (status == LocationAuthorizationStatus.authorizedAlways ||
//             status == LocationAuthorizationStatus.authorizedWhenInUse) {
//           wifiBSSID = await _networkInfo.getWifiBSSID();
//         } else {
//           wifiBSSID = await _networkInfo.getWifiBSSID();
//         }
//       } else {
//         wifiBSSID = await _networkInfo.getWifiBSSID();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi BSSID', error: e);
//       wifiBSSID = 'Failed to get Wifi BSSID';
//     }

//     try {
//       wifiIPv4 = await _networkInfo.getWifiIP();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi IPv4', error: e);
//       wifiIPv4 = 'Failed to get Wifi IPv4';
//     }

//     try {
//       wifiIPv6 = await _networkInfo.getWifiIPv6();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi IPv6', error: e);
//       wifiIPv6 = 'Failed to get Wifi IPv6';
//     }

//     try {
//       wifiSubmask = await _networkInfo.getWifiSubmask();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi submask address', error: e);
//       wifiSubmask = 'Failed to get Wifi submask address';
//     }

//     try {
//       wifiBroadcast = await _networkInfo.getWifiBroadcast();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi broadcast', error: e);
//       wifiBroadcast = 'Failed to get Wifi broadcast';
//     }

//     try {
//       wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi gateway address', error: e);
//       wifiGatewayIP = 'Failed to get Wifi gateway address';
//     }

//     try {
//       wifiSubmask = await _networkInfo.getWifiSubmask();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi submask', error: e);
//       wifiSubmask = 'Failed to get Wifi submask';
//     }
//     // Future.delayed(Duration(seconds: 40), () {
//     setState(() {
//       _connectionName = wifiName!;
//     });

//     // });
//     return wifiName ?? 'unknown';
//     // setState(() {
//     //   _connectionName = wifiName!;
//     // });
//   }

//   var previous_connectionName = "";
//   int _currentStep = 0;
//   StepperType stepperType = StepperType.horizontal;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Stepper Demo'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stepper(
//               type: stepperType,
//               physics: ScrollPhysics(),
//               elevation: 0,
//               currentStep: _currentStep,
//               onStepTapped: (step) => tapped(step),
//               steps: <Step>[
//                 Step(
//                   title: Text(''),
//                   content: Column(
//                     children: <Widget>[
//                       const Text(
//                           "Enter your phone's settings and select the desired device in the Wi-Fi section.\nHint : The name of the device will include 'ESP8266'\nHint : Password is '123456789' by default ",
//                           style: TextStyle(
//                             wordSpacing: 1.1,
//                           )),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       FutureBuilder(
//                           future: _initNetworkInfo(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               return Text(
//                                 snapshot.data.toString(),
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               );
//                             } else {
//                               return CircularProgressIndicator();
//                             }
//                           }),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       ElevatedButton(
//                           onPressed: (() {
//                             AppSettings.openWIFISettings();
//                           }),
//                           child: Text('Open Settings')),
//                       ElevatedButton(
//                         onPressed: (() {
//                           if (_connectionName.contains('zone')) {
//                             setState(() {
//                               _currentStep = 1;
//                             });
//                           } else {
//                             SnackBar snackBar = SnackBar(
//                               content: Text('Please connect to an ESP8266 device'),
//                               duration: Duration(seconds: 2),
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                           }
//                           // continued();
//                         }),
//                         child: Text('Continue'),
//                       )
//                     ],
//                   ),
//                   isActive: _currentStep > 0,
//                   state: _currentStep > 0 ? StepState.complete : StepState.disabled,
//                 ),
//                 Step(
//                   title: Text(''),
//                   content: Column(
//                     children: <Widget>[
//                       Text(
//                           'You are connected to $_connectionName\n Enter SSID and Password of your local network'),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           labelText: 'SSID',
//                         ),
//                       ),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: continued,
//                         child: Text('Connect'),
//                       ),
//                       ElevatedButton(
//                         onPressed: continued,
//                         child: Text('Continue'),
//                       ),
//                       ElevatedButton(onPressed: cancel, child: Text('Back')),
//                     ],
//                   ),
//                   isActive: _currentStep >= 1,
//                   state: _currentStep > 1 ? StepState.complete : StepState.disabled,
//                 ),
//                 Step(
//                   title: Text(''),
//                   content: Column(
//                     children: <Widget>[],
//                   ),
//                   isActive: _currentStep >= 2,
//                   state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
//                 ),
//               ],
//               controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) =>
//                   Container(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   switchStepsType() {
//     setState(() => stepperType == StepperType.vertical
//         ? stepperType = StepperType.horizontal
//         : stepperType = StepperType.vertical);
//   }

//   tapped(int step) {
//     setState(() => _currentStep = step);
//   }

//   continued() {
//     _currentStep < 2 ? setState(() => _currentStep += 1) : null;
//   }

//   cancel() {
//     _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
//   }
// }

class _ExpandRow extends StatelessWidget {
  const _ExpandRow({Key? key, required this.switches, required this.room}) : super(key: key);
  final List<Switch_> switches;
  final String room;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        room,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      children: switches.map((p) => SwitchTile(switchItem: p)).toList(),
    );
  }
}

class _ExpandRows extends StatelessWidget {
  const _ExpandRows({Key? key, required this.switches}) : super(key: key);
  final List<Switch_> switches;
  @override
  Widget build(BuildContext context) {
    List<_ExpandRow> rows = collections
        .map((room) =>
            _ExpandRow(switches: switches.where((s) => s.room == room).toList(), room: room))
        .toList();
    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        return rows[index];
      },
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
// class SwitchBottomSheet extends StatefulWidget {
//   const SwitchBottomSheet({Key? key, required this.switchItem}) : super(key: key);
//   final Switch_ switchItem;

//   @override
//   State<SwitchBottomSheet> createState() => _SwitchBottomSheetState();
// }

// class _SwitchBottomSheetState extends State<SwitchBottomSheet>{
//   Switch_ get switchItem => widget.switchItem;
//   TextEditingController _controller = TextEditingController();
//   @override
//   void initState() {
//     _controller.text = switchItem.name;
//     super.initState();
//   }
//   void updateSwitchName(String name) {
//     setState(() {
//       switchItem.name = name;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Text(
//               switchItem.name,
//               style: TextStyle(
//                 fontSize: 20,
//               ),
//             ),
//           ),
//           TextField(
//             controller: _controller,
//             decoration: const InputDecoration(
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.orange),
//                 borderRadius: BorderRadius.all(Radius.circular(25.0)),
//                 gapPadding: 5.0,
//               ),
//               labelText: 'Enter Name',
//               labelStyle: TextStyle(),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: ElevatedButton(
//                 onPressed: () {
//                   switchItem.rename(_controller.text);
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save')),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             children: <Widget>[],
//           ),
//         ],
//       ),
//     );
//   }
// }
