import 'package:cosinuss_app/models/panel_content.dart';
import 'package:flutter/material.dart';
import 'switch.dart';

class ExpansionPan extends StatefulWidget {
  const ExpansionPan({
    super.key,
    required this.onOn,
    required this.onOf,
    required this.connectionStatus,
    required this.earConnectFound,
  });

  final void Function() onOn;
  final void Function() onOf;
  final String connectionStatus;
  final bool earConnectFound;

  @override
  State<ExpansionPan> createState() => _ExpansionPanelState();
}

class _ExpansionPanelState extends State<ExpansionPan> {
  List<PanelContent> panelData = [];
  @override
  void initState() {
    super.initState();
    String status = widget.connectionStatus;
    panelData.add(PanelContent(
        header: "Bluetoothverbindung",
        body: SwitchButton(
          onOn: widget.onOn,
          onOf: widget.onOf,
          connectionStauts: widget.connectionStatus,
          earConnectFound: widget.earConnectFound,
        )));
    /*panelData.add(PanelContent(
        header: "Persönliche Angaben", body: const Text("Widget")));*/
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          panelData[index].isExpanded = isExpanded;
        });
      },
      children: panelData.map<ExpansionPanel>((PanelContent panelContent) {
        return ExpansionPanel(
          headerBuilder: (BuildContext contect, bool isExpanded) {
            return ListTile(
              title: Text(panelContent.header),
            );
          },
          body: Column(children: [panelContent.body]),
          isExpanded: panelContent.isExpanded,
        );
      }).toList(),
    );
  }
}
