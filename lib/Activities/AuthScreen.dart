// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:uni_links/uni_links.dart';

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

  // Initial deep link
  String initialDeepLink = '';
  // Deep link changes
  StreamSubscription? _deepLinkSub;

  @override
  void initState() {
    // Register Stream
    if (!kIsWeb) {
      _registerStream();
    }

    super.initState();

    Future<Duration?>.delayed(const Duration(seconds: 1), () async {
      try {
        final Future<bool> didAuthenticate = _localAuth.authenticate(
          biometricOnly: true,
          stickyAuth: true,
          localizedReason: AppLocalizations.of(context)!.translate('String80'),
        );
        didAuthenticate.then((bool value) {
          if (value) {
            final Future<String?> salt = _storage.read(key: 'Password');
            salt.then((String? value) async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        WalletWindow(value!, initialDeepLink)),
              );
            });
          }
        });
        //prevent the screen from rotating
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        SystemChrome.setPreferredOrientations(<DeviceOrientation>[
          DeviceOrientation.portraitUp,
        ]);
      } on PlatformException catch (e) {
        print("e: " + e.toString());
        if (e.code == auth_error.notAvailable) {
        } else if (e.code == auth_error.notEnrolled) {
        } else if (e.code == auth_error.passcodeNotSet) {
        } else if (e.code == auth_error.otherOperatingSystem) {}
      }
    });

    // Get initial deep link
    getInitialLink().then((String? initialLink) {
      if (initialLink != null) {
        setState(() {
          initialDeepLink = initialLink;
        });
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
                        final Future<bool> didAuthenticate =
                            _localAuth.authenticate(
                                biometricOnly: true,
                                localizedReason: AppLocalizations.of(context)!
                                    .translate('String80'),
                                stickyAuth: true);
                        didAuthenticate.then((bool value) {
                          if (value) {
                            final Future<String?> salt =
                                _storage.read(key: 'Password');
                            salt.then((String? value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WalletWindow(
                                          value!,
                                          initialDeepLink,
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
                        onFieldSubmitted: (String text) {
                          final Future<String?> salt =
                              _storage.read(key: 'Password');
                          salt.then((String? value) {
                            if (text == value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WalletWindow(value!, initialDeepLink)),
                              );
                            } else {
                              final SnackBar snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .translate('String2')));

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
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
                          fillColor: ColorTheme.of(context)!.depthColor,
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
                              color: Color(0xFF555555),
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
                            final Future<String?> salt =
                                _storage.read(key: 'Password');
                            salt.then((String? value) {
                              if (textController.text == value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WalletWindow(
                                              value!, initialDeepLink)),
                                );
                              } else {
                                final SnackBar snackBar = SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .translate('String2')));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
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

  // Register Stream
  void _registerStream() {
    // Deep link has been updated
    _deepLinkSub = linkStream.listen((String? link) {
      if (link != null) {
        setState(() {
          initialDeepLink = link;
        });
      }
    });
  }

  @override
  void dispose() {
    _destroyStream();
    super.dispose();
  }

  void _destroyStream() {
    if (_deepLinkSub != null) {
      _deepLinkSub!.cancel();
    }
  }
}
