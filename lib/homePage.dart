// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'Activities/AuthScreen.dart';
import 'Activities/ImportWallet.dart';
import 'Activities/NewWallet.dart';
import 'Data/Wallet.dart';

class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  bool? _walletCreated;
  bool _visibleButttons = false;

  @override
  void initState() {
    checkWallet().then((bool flag) {
      _walletCreated = flag;
      _walletCreated!
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
                child: Image.asset(
                  'images/Logo.png',
                  color: Colors.black,
                  width: 150.0,
                )),
            const Padding(padding: const EdgeInsets.symmetric(vertical: 30.0)),
            if (_visibleButttons)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewWalletScreen()),
                          );
                        },
                        child: Text(
                            AppLocalizations.of(context)!.translate('String65'),
                            style: const TextStyle(color: Colors.white)),
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20.0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImportWalletScreen()),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.translate('String66'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xffd42d72)),
              ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.translate('String39')),
                  const Icon(Icons.favorite, color: Colors.black),
                  Text(AppLocalizations.of(context)!.translate('String40'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
