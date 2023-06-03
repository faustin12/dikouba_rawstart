import 'package:dikouba_rawstart/AppTheme.dart';
import 'package:dikouba_rawstart/activity/welcome_activity.dart';
import 'package:dikouba_rawstart/model/user_model.dart';
import 'package:dikouba_rawstart/provider/databasehelper_provider.dart';
import 'package:dikouba_rawstart/utils/DikoubaColors.dart';
import 'package:dikouba_rawstart/utils/SizeConfig.dart';
//import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class DikoubaDrawerWidget extends StatefulWidget {
  UserModel userModel;

  DikoubaDrawerWidget(this.userModel,{required this.analytics, required this.observer});

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  DikoubaDrawerWidgetState createState() => DikoubaDrawerWidgetState();
}

class DikoubaDrawerWidgetState extends State<DikoubaDrawerWidget> {
  static final String TAG = 'DikoubaDrawerWidgetState';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () {

              },
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                accountName: Text(
                  widget.userModel.name!,
                  style: Theme.of(context).textTheme.headline6,
                ),
                accountEmail: Text(
                  widget.userModel.email!,
                  style: Theme.of(context).textTheme.caption,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).accentColor,
                  backgroundImage:
                  NetworkImage(widget.userModel.photo_url!),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/Pages', arguments: 2);
              },
              leading: Icon(
                Icons.home,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Accueil',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/Notification', arguments: 0);
              },
              leading: Icon(
                Icons.notifications,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Notification',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/MyEvent', arguments: 3);
              },
              leading: Icon(
                Icons.local_mall,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Locl mall',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/Favorites');
              },
              leading: Icon(
                Icons.favorite,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                "Favoris",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            /*ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Pages', arguments: 4);
            },
            leading: Icon(
              Icons.chat,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              S.of(context).messages,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),*/
            ListTile(
              dense: true,
              title: Text(
                'Preferences',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              trailing: Icon(
                Icons.remove,
                color: Theme.of(context).focusColor.withOpacity(0.3),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed('/Help');
              },
              leading: Icon(
                Icons.help,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Support',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
                signOut(context);
              },
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).focusColor.withOpacity(1),
              ),
              title: Text(
                'Se déconnecter',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Dikouba 1.0" ,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              trailing: Icon(
                Icons.remove,
                color: Theme.of(context).focusColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void signOut(BuildContext buildContext) async {
  /*
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("NON"),
      onPressed:  () {
        Navigator.of(buildContext).pop("non");
      },
    );
    Widget continueButton = FlatButton(
      child: Text("OUI"),
      onPressed:  () {
        Navigator.of(buildContext).pop("oui");
        // logoutUser(buildContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Déconnexion"),
      content: Text("Voulez-vous vraiment vous déconnecter ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    var resPrompt = await showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
    print("$TAG:resPrompt=$resPrompt");
    if(resPrompt == null || resPrompt == "non") return;*/

    logoutUser(buildContext);
  }

  void logoutUser(BuildContext buildContext) async {

    //await FirebaseAuthUi.instance().logout(); to be Corrected
    var dbHelper = DatabaseHelper.instance;
    await dbHelper.delete_user();

    Navigator.pushReplacement(
        buildContext,
        MaterialPageRoute(
          builder: (context) => WelcomeActivity(
            analytics: widget.analytics,
            observer: widget.observer,
          ),));
  }
}

