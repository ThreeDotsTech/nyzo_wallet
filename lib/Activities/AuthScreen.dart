// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    Future<Duration?>.delayed(const Duration(seconds: 1), () async {
      try {
        Future didAuthenticate;
        if (Platform.isIOS) {
          didAuthenticate = _localAuth.authenticate(
            biometricOnly: true,
            stickyAuth: true,
            localizedReason:
                AppLocalizations.of(context)!.translate('String80'),
          );
        } else {
          didAuthenticate = _localAuth.authenticate(
              biometricOnly: true,
              stickyAuth: true,
              localizedReason:
                  AppLocalizations.of(context)!.translate('String80'));
        }
        didAuthenticate.then((value) {
          if (value) {
            final Future salt = _storage.read(key: 'Password');
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
      child: Scaffold(
        backgroundColor: ColorTheme.of(context)!.baseColor,
        key: scaffoldMessengerKey,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 125.0, 0.0, 75.0),
                  child: InkWell(
                    onTap: () {
                      try {
                        final Future didAuthenticate = _localAuth.authenticate(
                            biometricOnly: true,
                            localizedReason: AppLocalizations.of(context)!
                                .translate('String80'),
                            stickyAuth: true);
                        didAuthenticate.then((value) {
                          if (value) {
                            final Future salt = _storage.read(key: 'Password');
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
                        color: ColorTheme.of(context)!.secondaryColor),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!.translate('String1'),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: ColorTheme.of(context)!.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 21.0,
                          )),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        onFieldSubmitted: (text) {
                          final Future salt = _storage.read(key: 'Password');
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
                                  content: Text(AppLocalizations.of(context)!
                                      .translate('String2')));

                              scaffoldMessengerKey.currentState!
                                ..showSnackBar(snackBar);
                            }
                          });
                        },
                        autocorrect: false,
                        autofocus: false,
                        obscureText: true,
                        controller: textController,
                        style: TextStyle(
                            color: ColorTheme.of(context)!.secondaryColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorTheme.of(context)!.dephtColor,
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(color: Colors.red)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(color: Colors.red)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide:
                                  const BorderSide(color: Color(0x55666666))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide:
                                  const BorderSide(color: Color(0x55666666))),
                          contentPadding: const EdgeInsets.all(10),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: AppLocalizations.of(context)!
                              .translate('String81'),
                          labelStyle: const TextStyle(
                              color: const Color(0xFF555555),
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: ColorTheme.of(context)!.secondaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            final Future salt = _storage.read(key: 'Password');
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
                                    content: Text(AppLocalizations.of(context)!
                                        .translate('String2')));

                                scaffoldMessengerKey.currentState!
                                  ..showSnackBar(snackBar);
                              }
                            });
                          },
                          child: Text(
                              AppLocalizations.of(context)!
                                  .translate('String3'),
                              style: TextStyle(
                                  color: ColorTheme.of(context)!.baseColor)),
                        ),
                      ),
                      Expanded(
                        child: Container(),
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
