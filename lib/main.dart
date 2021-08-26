// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/WatchedAddress.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';
import 'Data/Wallet.dart';
import 'homePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool lightTheme = false;
  Color baseColor = const Color(0xFFF5F5F5);
  Color secondaryColor = const Color(0xFF121212);
  Color depthColor = Colors.white;
  Color extraColor = Colors.black87;
  Color? transparentColor = Colors.grey[300];
  Color? highLightColor = Colors.grey[100];
  List<Verifier>? verifiersList;
  List<WatchedAddress>? addressesToWatch;
  List<List<String>>? balanceList;
  @override
  void initState() {
    downloadBalanceList();
    updateTheme();
    setVerifiers();
    super.initState();
  }

  void updateTheme() {
    getNightModeValue().then((bool? value) {
      setState(() {
        lightTheme = value ?? true;
        if (!lightTheme) {
          baseColor = const Color(0xFFF5F5F5);
          depthColor = Colors.white;
          secondaryColor = const Color(0xFF121212);
          extraColor = Colors.black87;
          transparentColor = Colors.grey[300];
          highLightColor = Colors.grey[100];
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        } else {
          baseColor = const Color(0xFF15151a);
          secondaryColor = const Color(0xFFF5F5F5);
          depthColor = const Color(0xFF1b1c20);
          extraColor = Colors.black;
          transparentColor = Colors.white30;
          highLightColor = Colors.white10;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColorTheme(
      lightTheme: lightTheme,
      update: updateTheme,
      baseColor: baseColor,
      secondaryColor: secondaryColor,
      extraColor: extraColor,
      depthColor: depthColor,
      transparentColor: transparentColor!,
      highLigthColor: highLightColor!,
      verifiersList: verifiersList,
      updateVerifiers: setVerifiers,
      addressesToWatch: addressesToWatch,
      getBalanceList: downloadBalanceList,
      balanceList: balanceList,
      updateAddressesToWatch: updateWatchAddresses,
      child: MaterialApp(
        supportedLocales: const <Locale>[
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('zh', 'CN'),
          Locale('nl', 'NL'),
          Locale('de', 'DE'),
          Locale('fr', 'FR'),
          Locale('hr', 'HR'),
          Locale('ru', 'RU'),
          Locale('cs', 'CZ')
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeListResolutionCallback:
            (List<Locale>? locales, Iterable<Locale> supportedLocales) {
          for (var eachLocale in locales!) {
            for (var eachSupportedLocale in supportedLocales) {
              if (eachLocale.languageCode == eachSupportedLocale.languageCode) {
                return eachSupportedLocale;
              }
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        title: 'Nyzo Wallet',
        home: HomePage(),
      ),
    );
  }

  Future<List<Verifier>?> setVerifiers() async {
    getVerifiers().then((List<Verifier> _verifiersList) {
      setState(() {
        verifiersList = _verifiersList;
      });
      return _verifiersList;
    });
  }

  void updateWatchAddresses() {
    getWatchAddresses().then((List<WatchedAddress> _list) {
      setState(() {
        addressesToWatch = _list;
        for (var eachAddress in addressesToWatch!) {
          try {
            eachAddress.balance =
                balanceList!.firstWhere((List<String> address) {
              return address[0] == eachAddress.address;
            })[1];
          } catch (e) {
            eachAddress.balance = '0';
          }
        }
      });
    });
  }

  void downloadBalanceList() {
    getBalanceList().then((List<List<String>> _balanceList) {
      setState(() {
        balanceList = _balanceList;
      });
      getWatchAddresses().then((List<WatchedAddress> _list) {
        setState(() {
          addressesToWatch = _list;
          for (var eachAddress in addressesToWatch!) {
            try {
              eachAddress.balance =
                  balanceList!.firstWhere((List<String> address) {
                return address[0] == eachAddress.address;
              })[1];
            } catch (e) {
              eachAddress.balance = '0';
            }
          }
        });
      });
    });
  }
}
