import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';

import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = new FlutterSecureStorage();
  var _localAuth = new LocalAuthentication();
  final textController = new TextEditingController();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () async {
      try {
        Future didAuthenticate;
        if (Platform.isIOS) {
          didAuthenticate = _localAuth.authenticateWithBiometrics(
            stickyAuth: true,
            localizedReason: AppLocalizations.of(context).translate("String80"),
          );
        } else {
          didAuthenticate = _localAuth.authenticateWithBiometrics(
              stickyAuth: true,
              localizedReason:
                  AppLocalizations.of(context).translate("String80"));
        }
        didAuthenticate.then((value) {
          if (value) {
            Future salt = _storage.read(key: "Password");
            salt.then((value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WalletWindow(
                          value,
                        )),
              );
            });
          }
        });
        //prevent the screen from rotating
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      } on PlatformException catch (e) {
        if (e.code == auth_error.notAvailable) {
        } else if (e.code == auth_error.notEnrolled) {
        } else if (e.code == auth_error.passcodeNotSet) {
        } else if (e.code == auth_error.otherOperatingSystem) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        backgroundColor: ColorTheme.of(context).baseColor,
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: new Center(
          child: new Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 125.0, 0.0, 75.0),
                  child: InkWell(
                    onTap: () {
                      try {
                        Future didAuthenticate =
                            _localAuth.authenticateWithBiometrics(
                                localizedReason: AppLocalizations.of(context)
                                    .translate("String80"),
                                stickyAuth: true);
                        didAuthenticate.then((value) {
                          if (value) {
                            Future salt = _storage.read(key: "Password");
                            salt.then((value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletWindow(
                                          value,
                                        )),
                              );
                            });
                          }
                        });
                      } on PlatformException catch (e) {
                        if (e.code == auth_error.notAvailable) {
                        } else if (e.code == auth_error.notEnrolled) {
                        } else if (e.code == auth_error.passcodeNotSet) {
                        } else if (e.code == auth_error.otherOperatingSystem) {}
                      }
                    },
                    child: Icon(Icons.fingerprint,
                        size: 75.0,
                        color: ColorTheme.of(context).secondaryColor),
                  ),
                ),
                new Expanded(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text(
                          AppLocalizations.of(context).translate("String1"),
                          textAlign: TextAlign.justify,
                          style: new TextStyle(
                            color: ColorTheme.of(context).secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 21.0,
                          )),
                      new SizedBox(
                        height: 40.0,
                      ),
                      new TextFormField(
                        onFieldSubmitted: (text) {
                          Future salt = _storage.read(key: "Password");
                          salt.then((value) {
                            if (text == value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletWindow(
                                          value,
                                        )),
                              );
                            } else {
                              final snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(context)
                                      .translate("String2")));

                              scaffoldKey.currentState..showSnackBar(snackBar);
                            }
                          });
                        },
                        autocorrect: false,
                        autofocus: false,
                        obscureText: true,
                        controller: textController,
                        style: TextStyle(
                            color: ColorTheme.of(context).secondaryColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorTheme.of(context).dephtColor,
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.red)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.red)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Color(0x55666666))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Color(0x55666666))),
                          contentPadding: EdgeInsets.all(10),
                          hasFloatingPlaceholder: false,
                          labelText: AppLocalizations.of(context)
                              .translate("String81"),
                          labelStyle: TextStyle(
                              color: Color(0xFF555555),
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: RaisedButton(
                          color: ColorTheme.of(context).secondaryColor,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Future salt = _storage.read(key: "Password");
                            salt.then((value) {
                              if (textController.text == value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WalletWindow(
                                            value,
                                          )),
                                );
                              } else {
                                final snackBar = SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .translate("String2")));

                                scaffoldKey.currentState
                                  ..showSnackBar(snackBar);
                              }
                            });
                          },
                          child: new Text(
                              AppLocalizations.of(context).translate("String3"),
                              style: TextStyle(
                                  color: ColorTheme.of(context).baseColor)),
                        ),
                      ),
                      new Expanded(
                        child: new Container(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
