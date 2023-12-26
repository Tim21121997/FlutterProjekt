import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  const SwitchButton({
    super.key,
    required this.onOn,
    required this.onOf,
    required this.connectionStauts,
    required this.earConnectFound,
  });
  final void Function() onOn;
  final void Function() onOf;
  final String connectionStauts;
  final bool earConnectFound;

  @override
  State<SwitchButton> createState() => _SwitchState();
}

class _SwitchState extends State<SwitchButton> {
  bool? light;
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  @override
  void initState() {
    super.initState();
    light = (widget.connectionStauts == "Disconnected") ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbIcon: thumbIcon,
      value: light!,
      onChanged: (bool value) {
        if (value == true && widget.connectionStauts == "Disconnected") {
          widget.onOn();
        } else {
          widget.onOf();
        }
        setState(() {
          light = value;
        });
      },
    );
  }
}
