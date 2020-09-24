import 'package:flutter/material.dart';

import 'helpDialog.dart';

class HelpButton extends StatelessWidget {
  final String titleText, helpText;
  HelpButton(this.titleText, this.helpText);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: const Text(
        "Help",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => HelpDialog(titleText, helpText),
        );
      },
    );
  }
}
