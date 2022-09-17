// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:http/http.dart' as http;
import 'package:uitest/mqtt_config.dart';
import 'package:wifi_iot/wifi_iot.dart';

Future<void> makePostRequest(String value) async {
  final url = Uri.parse('http://192.168.4.1/flutter/posts?value=$value');
  http.get(url);
}

class AddSwitchPage extends StatefulWidget {
  const AddSwitchPage({Key? key}) : super(key: key);

  @override
  State<AddSwitchPage> createState() => _AddSwitchPageState();
}

class _AddSwitchPageState extends State<AddSwitchPage> {
  bool connected = false;
  String? _connectionName;
  String? registerUID;
  int? pins;
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _networkInfo = NetworkInfo();
  @override
  void initState() {
    super.initState();
    // setupMqttClient();
    setupUpdatesListener();
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    MQobject.unSubscribe("${registerUID!}/${MQobject.registerTopic}");

    super.dispose();
  }

  Future<bool> requestWifiInfoPermisson() async {
    print('Checking Android permissions');

    PermissionStatus status = await Permission.location.status;
    // Blocked?
    if (status.isDenied || status.isRestricted) {
      // Ask the user to unblock
      if (await Permission.location.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        print('Location permission granted');
        return true;
      } else {
        print('Location permission not granted');
        return false;
      }
    } else {
      print('Permission already granted (previous execution?)');
      return true;
    }
  }

  Future<String?> _initNetworkInfo() async {
    String? wifiName;
    bool isGranted = await requestWifiInfoPermisson();
    if (isGranted) {
      try {
        if (!kIsWeb && Platform.isIOS) {
          var status = await _networkInfo.getLocationServiceAuthorization();
          if (status == LocationAuthorizationStatus.notDetermined) {
            status = await _networkInfo.requestLocationServiceAuthorization();
          }
          if (status == LocationAuthorizationStatus.authorizedAlways ||
              status == LocationAuthorizationStatus.authorizedWhenInUse) {
            wifiName = await _networkInfo.getWifiName();
          } else {
            wifiName = await _networkInfo.getWifiName();
          }
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } on PlatformException catch (e) {
        developer.log('Failed to get Wifi Name', error: e);
        wifiName = 'Failed to get Wifi Name';
      }
    }
    _connectionName = wifiName;

    return wifiName;
  }

  var previous_connectionName = "";
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(""),
          centerTitle: true,
          actions: [
            (_currentStep == 0)
                ? IconButton(onPressed: () => setState(() {}), icon: Icon(Icons.refresh))
                : Container(),
            IconButton(
                onPressed: switchStepsType,
                icon: stepperType == StepperType.vertical
                    ? Icon(Icons.swap_horizontal_circle_outlined)
                    : Icon(Icons.swap_vertical_circle_outlined))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stepper(
                type: stepperType,
                physics: ScrollPhysics(),
                elevation: 0,
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                steps: <Step>[
                  Step(
                    title: Text(''),
                    content: Column(
                      children: <Widget>[
                        const Text(
                            "Enter your phone's settings and select the desired device in the Wi-Fi section.\nHint : The name of the device will include 'ESP8266'\nHint : Password is '123456789' by default ",
                            style: TextStyle(
                              wordSpacing: 1.1,
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FutureBuilder(
                            future: _initNetworkInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data.toString(),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (() {
                                AppSettings.openWIFISettings();
                              }),
                              child: Text('Open Settings')),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (() {
                              // if (_connectionName.contains('zone')) {
                              //   setState(() {
                              //     _currentStep = 1;
                              //   });
                              // } else {
                              //   SnackBar snackBar = SnackBar(
                              //     content: Text('Please connect to an ESP8266 device'),
                              //     duration: Duration(seconds: 2),
                              //   );
                              //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              // }

                              continued();
                            }),
                            child: Text('Continue'),
                          ),
                        )
                      ],
                    ),
                    isActive: _currentStep > 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: Text(''),
                    content: Column(
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: ssidController,
                                decoration: InputDecoration(
                                  labelText: 'SSID',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter SSID';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (() {
                              if (_formKey.currentState!.validate()) {
                                registerUID =
                                    _connectionName!.substring(1, _connectionName!.length - 1);
                                print(registerUID);
                                makePostRequest(generate_value());
                                FocusManager.instance.primaryFocus?.unfocus();
                                Future.doWhile(() async => await Future.delayed(
                                      Duration(seconds: 5),
                                      () {
                                        return WiFiForIoTPlugin.connect('a.zone',
                                            password: '123789\$@ali',
                                            security: NetworkSecurity.WPA,
                                            withInternet: true,
                                            joinOnce: false);
                                      },
                                    ));
                                continued();
                              }
                            }),
                            style: ElevatedButton.styleFrom(primary: Color(0xFF344955)),
                            child: Text('Connect'),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                ssidController.clear();
                                passwordController.clear();
                                _formKey.currentState?.reset();
                                cancel();
                              },
                              child: Text('Back')),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    //TODO :  show switches witch added in previous step
                    title: Text(''),
                    content: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // WiFiForIoTPlugin.connect('a.zone', password: '123789\$@ali',security: NetworkSecurity.WPA , withInternet: true ,joinOnce: false);
                                MQobject.subscribe(
                                    "${registerUID!}/${MQobject.registerTopic.toString()}",
                                    MqttQos.atLeastOnce);
                              },
                              child: Text("Retry"),
                            )),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () => addNewPairedSW(pins!), child: Text("Confirm")))
                      ],
                    ),
                    isActive: _currentStep >= 2,
                    state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
                  ),
                ],
                //for disable default buttons
                controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) =>
                    Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generate_value() {
    String value = "";
    int ssidLength = ssidController.text.length;
    int passLength = passwordController.text.length;
    if (ssidLength + passLength < 10) value = '0';
    value += (ssidLength + passLength).toString();
    if (ssidLength < 10) value += '0';
    value += ssidLength.toString() + ssidController.text + passwordController.text;
    return value;
  }

  Future<void> setupMqttClient() async {
    await MQobject.connect();
    // MQobject.subscribe("$_connectionName/${MQobject.registerTopic}", MqttQos.atLeastOnce);
    //MQobject.subscribe(MQobject.registerTopic, MqttQos.atLeastOnce);
  }

  void setupUpdatesListener() {
    MQobject.getMessagesStream()!.listen((List<MqttReceivedMessage<MqttMessage?>>? massage) {
      final recMess = massage![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      var topic = massage[0].topic;
      print('MQTTClient::Message received on topic: <$topic> is $payload\n');

      if (topic == "${registerUID!}/${MQobject.registerTopic}" && payload.isNotEmpty) {
        var encoded = jsonDecode(payload);
        pins = encoded["pins"];

        //addNewPairedSW(pins);
      }
    });
  }

  void addNewPairedSW(int pins) {
    for (int i = 0; i < pins; i++) {
      final switchData = {
        "id": Uuid().v1(),
        "name": "${registerUID!} - $i",
        "room": "All",
        "state": false,
        "icon": "assets/images/plug.png"
      };
      Map<String, Map> updates = {};
      updates['All/test/${switchData["id"]}'] = switchData;
      FirebaseDatabase.instance.ref().update(updates);
      print(i);
    }
    MQobject.publishMessage("${registerUID!}/${MQobject.registerTopic}", "");
    print(pins);
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
