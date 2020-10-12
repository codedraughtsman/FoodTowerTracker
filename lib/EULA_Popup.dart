import 'package:flutter/material.dart';
import 'package:foodtowertracker/DataBase.dart';

class EULA_Popup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return showDialogIfFirstLoaded(context);
  }

  showDialogIfFirstLoaded(BuildContext context) async {
    bool isFirstTime = true;
    if (isFirstTime) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Title"),
            content: SingleChildScrollView(
              child: Text(DBProvider.StringEULA_Text),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Dismiss"),
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                  //prefs.setBool(keyIsFirstLoaded, false);
                },
              ),
            ],
          );
        },
      );
    }
  }
}
