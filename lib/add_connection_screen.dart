// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables, avoid_print
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:http/http.dart' as http;
import 'package:uitest/models/mqtt_config.dart';
import 'package:wifi_iot/wifi_iot.dart';

MQTTClientManager MQobject = MQTTClientManager();

Future<void> makePostRequest(String value) async {
  final url = Uri.parse('http://192.168.4.1/flutter/posts?value=$value');
  final response = await http.get(url);
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
}

class AddSwitchPage extends StatefulWidget {
  const AddSwitchPage({Key? key}) : super(key: key);

  @override
  State<AddSwitchPage> createState() => _AddSwitchPageState();
}

class _AddSwitchPageState extends State<AddSwitchPage> {
  bool connected = false;
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    // setupUpdatesListener();
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<String?> getSSID() async {
    String? ssidname = await WiFiForIoTPlugin.getSSID();
    return ssidname;
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
          title: Text('Flutter Stepper Demo'),
          centerTitle: true,
          actions: [
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
                            future: getSSID(),
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
                                makePostRequest(generate_value());

                                //MQobject.subscribe("register/000", MqttQos.atLeastOnce);

                                continued;
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
                    title: Text(''),
                    content: Column(
                      children: <Widget>[],
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
    //MQobject.subscribe('', MqttQos.atLeastOnce);
  }

  void setupUpdatesListener() {
    MQobject.getMessagesStream()!.listen((List<MqttReceivedMessage<MqttMessage?>>? massage) {
      final recMess = massage![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('MQTTClient::Message received on topic: <${massage[0].topic}> is $payload\n');

      if (massage[0].topic == MQobject.registerTopic) {
        var encoded = jsonDecode(payload);
        int pins = encoded["poles"];
        print(pins);
      }
    });
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
