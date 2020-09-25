import 'package:flutter/material.dart';

class HelpDialog extends StatefulWidget {
  String titleText, helpText;
  HelpDialog(this.titleText, this.helpText);
  @override
  _HelpDialogState createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 16,
      child: Container(
        height: 400.0,
        width: 360.0,
        child: Padding(
          padding:
              EdgeInsets.only(top: 16.0, bottom: 16.0, left: 20.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Text(
                  widget.titleText,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Text(
                  widget.helpText,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
