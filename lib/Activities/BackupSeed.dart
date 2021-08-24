

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class BackUpSeed extends StatefulWidget {
  BackUpSeed(this._password);
  final String _password;
  @override
  _BackUpSeedState createState() => _BackUpSeedState(_password);
}

class _BackUpSeedState extends State<BackUpSeed> {
  _BackUpSeedState(this._password);
  final String _password;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _privKey = "";
  bool isBacked = false;
  @override
  void initState() {
    getPrivateKey(_password).then((String privKey) {
      setState(() {
        _privKey = nyzoStringFromPrivateKey(privKey);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.of(context)!.baseColor,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: new Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Center(
                      child: new Text(
                          AppLocalizations.of(context)!.translate("String4"),
                          style: new TextStyle(
                            color: ColorTheme.of(context)!.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          )))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context)!.translate("String100"),
                  style: new TextStyle(
                    color: ColorTheme.of(context)!.secondaryColor,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(100.0)),
                      color: ColorTheme.of(context)!.secondaryColor,
                      onPressed: () {
                        Clipboard.setData(new ClipboardData(text: _privKey));
                        final snackBar = SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .translate("String5")));

                        _scaffoldKey.currentState!..showSnackBar(snackBar);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _privKey,
                          style: TextStyle(
                              color: ColorTheme.of(context)!.baseColor,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100.0),
                    child: Text(
                      AppLocalizations.of(context)!.translate("String6"),
                      style: TextStyle(
                          color: ColorTheme.of(context)!.secondaryColor,
                          fontSize: 15),
                    ),
                  ),
                  RaisedButton(
                    color: ColorTheme.of(context)!.secondaryColor,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text(
                        AppLocalizations.of(context)!.translate("String7"),
                        style:
                            TextStyle(color: ColorTheme.of(context)!.baseColor)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
