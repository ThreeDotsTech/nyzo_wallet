import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';

class ImportWalletScreen2 extends StatefulWidget {
  ImportWalletScreen2(this._privKey);
  final String _privKey;
  @override
  _ImportWalletScreen2State createState() =>
      _ImportWalletScreen2State(_privKey);
}

class _ImportWalletScreen2State extends State<ImportWalletScreen2> {
  _ImportWalletScreen2State(this._privKey);
  final String _privKey;
  bool _isLoading = false;
  final textController1 = new TextEditingController();
  final textController2 = new TextEditingController();
  final privKeytextController = new TextEditingController();
  final formKey = new GlobalKey<FormFieldState>();
  @override
  void initState() {
    super.initState();
    //prevent the screen from rotating
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    textController2.dispose();
    textController1.dispose();
    super.dispose();
  }

  void _performWalletCreation() {
    setState(() {
      _isLoading = true;
    });
    importWallet(_privKey, textController1.text).then((bool onValue) {


      //onValue not used
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WalletWindow(textController1.text)),
      );

      ///this.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: new IconButton(
            color: const Color(0xFFFFFFFF),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: new Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Center(
                      child: new Text(AppLocalizations.of(context).translate("String16"),
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          )))),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new TextFormField(
                    autocorrect: false,
                    autofocus: false,
                    obscureText: true,
                    controller: textController1,
                    style: TextStyle(color: Colors.black),
                    decoration: new InputDecoration(
                      labelText: 	AppLocalizations.of(context).translate("String81"),
                    ),
                  ),
                  new TextFormField(
                    key: formKey,
                    autocorrect: false,
                    controller: textController2,
                    obscureText: true,
                    style: TextStyle(color: Colors.black),
                    decoration:
                        new InputDecoration(labelText: 	AppLocalizations.of(context).translate("String84")),
                    validator: (val) => val != textController1.text
                        ? 	AppLocalizations.of(context).translate("String85")
                        : val == '' ? 	AppLocalizations.of(context).translate("String86"):null,
                  ),
                  new SizedBox(
                    height: 50.0,
                  ),
                  _isLoading
                      ? Center(
                          child: new CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation(
                                  Color(0XFFFFFFFF))))
                      : Center(
                          child: new RaisedButton(
                            color: Colors.black87,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            onPressed: () {
                              final form = formKey.currentState;
                              if (form.validate()) {
                                _performWalletCreation();
                              }
                            },
                            child: new Text(AppLocalizations.of(context).translate("String17"),style: TextStyle(color: Colors.white)),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ));
  }
}
