import 'package:flutter/material.dart';

class PanelContent {
  bool isExpanded;
  String header;
  Widget body;
  Icon? iconPic;

  PanelContent(
      {this.isExpanded = false,
      required this.header,
      required this.body,
      this.iconPic});
}
