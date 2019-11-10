import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'Data/Wallet.dart';
import 'Activities/NewWallet.dart';
import 'Activities/AuthScreen.dart';
import 'Activities/ImportWallet.dart';

class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {

  bool _walletCreated;
  bool _visibleButttons = false;

  changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color);
    } on PlatformException catch (e) {}
  }

  @override
  void initState() {
    checkWallet().then((bool flag) {
      _walletCreated = flag;
      _walletCreated
          ? setState(() {
              //if it does, go to the password activity
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            })
          : setState(() {
              _visibleButttons = true;
            });
    });
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    changeStatusColor(Colors.transparent);
    super.initState();
    //prevent the screen from rotating
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
                child: new Image.asset(
                  "images/Logo.png",
                  color: Colors.black,
                  width: 150.0,
                )),
            new Padding(padding: EdgeInsets.symmetric(vertical: 30.0)),
            _visibleButttons
                ? new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Padding(
                          padding: new EdgeInsets.symmetric(horizontal: 70.0),
                          child: RaisedButton(
                            color: Colors.black87,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewWalletScreen()),
                              );
                            },
                            child: Text(AppLocalizations.of(context).translate("String65"),
                                style: TextStyle(color: Colors.white)),
                          )),
                      new Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0)),
                      new Padding(
                        padding: new EdgeInsets.symmetric(horizontal: 70.0),
                        child: RaisedButton(
                          color: Colors.black87,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImportWalletScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).translate("String66"),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : new CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation(Color(0XFFD42D72)),
                  ),
            new Expanded(
              child: new Container(),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(AppLocalizations.of(context).translate("String39")),
                new Icon(Icons.favorite, color: Colors.black),
                new Text(AppLocalizations.of(context).translate("String40"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
