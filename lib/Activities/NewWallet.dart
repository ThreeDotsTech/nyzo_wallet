import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Activities/BackupSeed.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class NewWalletScreen extends StatefulWidget {
  @override
  _NewWalletScreenState createState() => _NewWalletScreenState();
}

class _NewWalletScreenState extends State<NewWalletScreen> {
  bool _isLoading = false;
  final textController1 = new TextEditingController();
  final textController2 = new TextEditingController();
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

    createNewWallet(textController1.text).then((onValue) {
      ColorTheme.of(context).update();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WalletWindow(textController1.text)),
      );
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
            color: Colors.black,
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
                      child: new Text(
                          AppLocalizations.of(context).translate("String18"),
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
                      labelText:
                          AppLocalizations.of(context).translate("String81"),
                      labelStyle: TextStyle(
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  new TextFormField(
                    key: formKey,
                    autocorrect: false,
                    controller: textController2,
                    obscureText: true,
                    style: TextStyle(color: Colors.black),
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
                      labelText:
                          AppLocalizations.of(context).translate("String84"),
                      labelStyle: TextStyle(
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    validator: (val) => val != textController1.text
                        ? AppLocalizations.of(context).translate("String85")
                        : val == ''
                            ? AppLocalizations.of(context).translate("String86")
                            : val.length < 6
                                ? AppLocalizations.of(context)
                                    .translate("String101")
                                : null,
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
                            child: new Text(
                                AppLocalizations.of(context)
                                    .translate("String19"),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ));
  }
}
