// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables
import 'package:network_info_plus/network_info_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;

const String broker = 'test.mosquitto.org';
const int port = 1883;
Future<void> _makePostRequest(String value) async {
  final url = Uri.parse('http://192.168.4.1/flutter/posts?value=$value');
  final response = await http.get(url);
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
}

final client = MqttServerClient.withPort(broker, '', port);
void connect() async {
  print('connecting');
  client.setProtocolV311();
  //client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  //client.port = port;
  // client.secure = true;
  // client.securityContext = SecurityContext.defaultContext;
  client.logging(on: true);
  client.keepAlivePeriod = 60;
  client.onConnected = () => print('connected');
  client.onDisconnected = onDisconnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  final connMessage = MqttConnectMessage().startClean()
      // .withWillTopic('willtopic')
      // .withWillMessage('Will message')
      // .withWillQos(MqttQos.atLeastOnce)
      ;
  client.connectionMessage = connMessage;
  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }
  StreamSubscription ppi =
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messageList) {
    final MqttPublishMessage recieveMess = messageList[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recieveMess.payload.message);
    if (messageList[0].topic == "register/000") {}
    print(
        'EXAMPLE::Change notification:: topic is <${messageList[0].topic}>, payload is <-- $payload -->');
    print('');
  });
}

void onConnected() => print('Connected');
void onDisconnected() => print('Disconnected');
void onSubscribed(String topic) => print('Subscribed topic: $topic');
void pong() => print('Ping response client callback invoked');

void _publish(String message) {
  final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

  builder.clear();
  builder.addString(message);

  print('Publishing message "$message" to topic ${'iot/flutter/mytest'}');
  client.publishMessage('iot/flutter/mytest', MqttQos.exactlyOnce, builder.payload!);
}

class AddSwitchPage extends StatefulWidget {
  const AddSwitchPage({Key? key}) : super(key: key);

  @override
  State<AddSwitchPage> createState() => _AddSwitchPageState();
}

class _AddSwitchPageState extends State<AddSwitchPage> {
  String _connectionName = "";
  bool connected = false;
  final _networkInfo = NetworkInfo();
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
    connect();
  }

  Future<String> _initNetworkInfo() async {
    String? wifiName, wifiBSSID, wifiIPv4, wifiIPv6, wifiGatewayIP, wifiBroadcast, wifiSubmask;

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

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      wifiIPv6 = await _networkInfo.getWifiIPv6();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      wifiBroadcast = await _networkInfo.getWifiBroadcast();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    try {
      wifiSubmask = await _networkInfo.getWifiSubmask();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask', error: e);
      wifiSubmask = 'Failed to get Wifi submask';
    }
    setState(() {
      _connectionName = wifiName ?? "";
      if (_connectionName != "") {
        connected = true;
      } else {
        connected = false;
      }
    });
    return wifiName ?? 'unknown';
  }

  var previous_connectionName = "";
  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Stepper Demo'),
        centerTitle: true,
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
                      // FutureBuilder(
                      //     future:connected? _initNetworkInfo() : null,
                      //     builder: (context, snapshot) {
                      //       if (snapshot.hasData) {
                      //         previous_connectionName = _connectionName;
                      //         return Text(
                      //           snapshot.data.toString(),
                      //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      //         );
                      //       } else {
                      //         return CircularProgressIndicator();
                      //       }
                      //     }),
                      Text(_connectionName),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: (() {
                            AppSettings.openWIFISettings();
                          }),
                          child: Text('Open Settings')),
                      ElevatedButton(
                        onPressed: (() {
                          if (_connectionName.contains('Phone')) {
                            setState(() {
                              _currentStep = 1;
                            });
                          } else {
                            SnackBar snackBar = SnackBar(
                              content: Text('Please connect to an ESP8266 device'),
                              duration: Duration(seconds: 2),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                          // continued();
                        }),
                        child: Text('Continue'),
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
                      Text(
                          'You are connected to $_connectionName\n Enter SSID and Password of your local network'),
                      TextFormField(
                        controller: ssidController,
                        validator: (value) => value!.isEmpty ? 'SSID is required' : null,
                        decoration: InputDecoration(
                          labelText: 'SSID',
                        ),
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (() {
                          // String value = "";
                          // int ssidLength = ssidController.text.length;
                          // int passLength = passwordController.text.length;
                          // if (ssidLength + passLength < 10) value = '0';
                          // value += (ssidLength + passLength).toString();
                          // if (ssidLength < 10) value += '0';
                          // value +=
                          //     ssidLength.toString() + ssidController.text + passwordController.text;
                          // _makePostRequest(value);
                          client.subscribe("register/000", MqttQos.atMostOnce);
                          continued;
                        }),
                        child: Text('Connect'),
                      ),
                      ElevatedButton(onPressed: cancel, child: Text('Back')),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.disabled,
                ),
                Step(
                  title: Text(''),
                  content: Column(
                    children: <Widget>[],
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
                ),
              ],
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) =>
                  Container(),
            ),
          ),
        ],
      ),
    );
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
