// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class BackUpSeed extends StatefulWidget {
  const BackUpSeed(this._password);
  final String _password;
  @override
  _BackUpSeedState createState() => _BackUpSeedState(_password);
}

class _BackUpSeedState extends State<BackUpSeed> {
  _BackUpSeedState(this._password);
  final String _password;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _privKey = '';
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
        key: scaffoldMessengerKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Center(
                      child: Text(
                          AppLocalizations.of(context)!.translate('String4'),
                          style: TextStyle(
                            color: ColorTheme.of(context)!.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          )))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context)!.translate('String100'),
                  style: TextStyle(
                    color: ColorTheme.of(context)!.secondaryColor,
                    fontSize: 15.0,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: ColorTheme.of(context)!.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0))),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _privKey));
                        final SnackBar snackBar = SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .translate('String5')));

                        scaffoldMessengerKey.currentState!
                          ..showSnackBar(snackBar);
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
                      AppLocalizations.of(context)!.translate('String6'),
                      style: TextStyle(
                          color: ColorTheme.of(context)!.secondaryColor,
                          fontSize: 15),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: ColorTheme.of(context)!.secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                        AppLocalizations.of(context)!.translate('String7'),
                        style: TextStyle(
                            color: ColorTheme.of(context)!.baseColor)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
