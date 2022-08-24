import 'package:flutter/material.dart';

class SwitchTile extends StatefulWidget {
  final Switch_ switchItem;

  const SwitchTile({required this.switchItem, Key? key}) : super(key: key);

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 216, 125, 125),
        backgroundImage: Image.asset(widget.switchItem.icon).image,
        radius: 20,
        // child:
        //     Image.asset(switchItem.icon , fit: BoxFit.scaleDown),
      ),
      title: Text(widget.switchItem.name),
      subtitle: Text(widget.switchItem.room),
      trailing: ElevatedButton(
        onPressed: () {
          setState(() {
            widget.switchItem.state ? widget.switchItem.turnOff(widget.switchItem.name) : widget.switchItem.turnOn(widget.switchItem.name);
          });
        },
        style: ElevatedButton.styleFrom(
          primary: widget.switchItem.state ? Colors.teal.shade800 : Colors.redAccent.shade700,
          fixedSize: const Size(90, 30),
          elevation: 10,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: widget.switchItem.state
              ? const BorderSide(
                  color: Colors.white,
                  width: 4,
                )
              : const BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
        ),
        child: Text(widget.switchItem.state ? "Turn ON" : "Turn OFF"),
      ),
    );
  }
}
// ignore: camel_case_types
class Switch_ {
  String name;
  final double id;
  bool state; //true if switched on, false if switched off
  String? switchType; // switchType of the switch (e.g. "Light", "Fan", "AC")
  String icon; //the icon of the switch (e.g. "light", "fan", "ac")
  String room; //the room of the switch (e.g. "Living Room", "Bed Room", "Kitchen")
  Switch_(
      {required this.name,
      required this.id,
      required this.state,
      switchType,
      this.icon = "light", //default icon is light
      required this.room});

  void turnOn(name) {
    print("$name is on");
    this.state = true;
  }

  void turnOff(name) {
    print("$name is off");
    this.state = false ; 
  }

  void rename(name) {
    this.name = name;
  }
}
