import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Activities/SettingsWindow.dart';
import 'package:nyzo_wallet/Activities/verifiersWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/NyzoMessage.dart';
import 'package:nyzo_wallet/Data/NyzoString.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:flutter/services.dart';
import 'package:nyzo_wallet/Data/watchedAddress.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';
import 'package:nyzo_wallet/Widgets/TransactionsWidget.dart';
import 'package:nyzo_wallet/Widgets/verifierDialog.dart';
import "package:hex/hex.dart";

import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:nyzo_wallet/Data/Transaction.dart';
import 'package:nyzo_wallet/Activities/SendWindow.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Activities/ContactsWindow.dart';
import 'package:unicorndial/unicorndial.dart';

class WalletWindow extends StatefulWidget {
  final _password;
  WalletWindow(this._password);
  @override
  WalletWindowState createState() => WalletWindowState(_password);
}

class WalletWindowState extends State<WalletWindow> {
  WalletWindowState(this.password);

  ContactsWindow contactsWindow = ContactsWindow(_contactsList);
  TranSactionsWidget tranSactionsWidgetInstance = TranSactionsWidget(null);
  VerifiersWindow verifiersWindow;
  SendWindow sendWindowInstance;
  SettingsWindow settingsWindow = SettingsWindow();

  String password;
  double screenHeight;

  int balance = 0;
  String _address = '';
  static List<Transaction> transactions;
  static List<Contact> _contactsList;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var f = new NumberFormat("###.0#", "en_US");
  bool _compactFormat = true;
  int pageIndex = 0;

  bool sentinels = false;

  final textControllerAmount = new TextEditingController();
  final textControllerAddress = new TextEditingController();
  final textControllerData = new TextEditingController();
  final amountFormKey = new GlobalKey<FormFieldState>();
  final addressFormKey = new GlobalKey<FormFieldState>();
  final dataFormKey = new GlobalKey<FormFieldState>();

  AddVerifierDialog floatingdialog = AddVerifierDialog();

  changeTheme(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    getSavedBalance().then((double _balance) {
      setState(() {
        balance = _balance.floor();
      });
    });
    verifiersWindow = VerifiersWindow();

    watchSentinels().then((bool val) {
      setState(() {
        sentinels = val;
      });
    });
    getAddress().then((address) {
      //load the address from disk
      setState(() {
        _address = address;
        //NyzoString _string = NyzoStringEncoder.decode(_address);
        
        sendWindowInstance = new SendWindow(password, nyzoStringFromPublicIdentifier(_address));

        getBalance(_address).then((_balance) {
          //get the balance value from the network
          setState(() {
            balance = _balance;
            setSavedBalance(double.parse(balance.toString())); //set the balance
          });
          getTransactions(_address).then((List transactions) {
            transactions = transactions;
          });
        }); //set the address
      });
      getContacts().then((contactList) {
        _contactsList = contactList;
      });
    });

    super.initState();

    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    //prevent the screen from rotating
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  changeFormat() {
    setState(() {
      _compactFormat = !_compactFormat;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: 	AppLocalizations.of(context).translate("String96"),
        currentButton: FloatingActionButton(
          heroTag: "verifier",
          backgroundColor: ColorTheme.of(context).baseColor,
          mini: true,
          child: Container(
              margin: EdgeInsets.all(8),
              child: Image.asset(
                "images/normal.png",
                color: ColorTheme.of(context).secondaryColor,
              )),
          onPressed: () {
            floatingdialog.information(context, 	AppLocalizations.of(context).translate("String97"), true,
                onClose: () {
              ColorTheme.of(context).updateVerifiers();
              
            });
          },
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: 	AppLocalizations.of(context).translate("String98"),
        currentButton: FloatingActionButton(
          heroTag: "address",
          backgroundColor: ColorTheme.of(context).baseColor,
          mini: true,
          child: Icon(
            Icons.account_balance_wallet,
            color: ColorTheme.of(context).secondaryColor,
          ),
          onPressed: () {
            setState(() {
              floatingdialog.information(context, 	AppLocalizations.of(context).translate("String97"), false,
                  onClose: () {
                ColorTheme.of(context).updateAddressesToWatch();
              });
            });
          },
        )));
    return WillPopScope(
      // widget to control the moving between activities
      onWillPop: () async =>
          false, //don't let the user go back to the previous activity
      child: Scaffold(
        floatingActionButton: sentinels
            ? pageIndex == 3
                ? UnicornDialer(
                    parentHeroTag: "ParenTagg",
                    childButtons: childButtons,
                    parentButtonBackground: ColorTheme.of(context).baseColor,
                    backgroundColor: Colors.black12,
                    finalButtonIcon: Icon(
                      Icons.close,
                      color: ColorTheme.of(context).secondaryColor,
                    ),
                    parentButton: Container(
                        margin: EdgeInsets.all(15),
                        child: Icon(
                          Icons.add,
                          color: ColorTheme.of(context).secondaryColor,
                        )),
                  )
                : null
            : null,
        //resizeToAvoidBottomInset: false,
        // resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: ColorTheme.of(context).baseColor,
        bottomNavigationBar: TitledBottomNavigationBar(
            indicatorColor: ColorTheme.of(context).secondaryColor,
            inactiveColor: ColorTheme.of(context).secondaryColor,
            activeColor: ColorTheme.of(context).secondaryColor,
            reverse: true,
            currentIndex:
                pageIndex, // Use this to update the Bar giving a position
            onTap: (index) {
              setState(() {
                FocusScope.of(context).requestFocus(new FocusNode());
                pageIndex = index;
              });
            },
            items: sentinels
                ? [
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 	AppLocalizations.of(context).translate("String72"),
                        icon: Icons.history),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 	AppLocalizations.of(context).translate("String8"),
                        icon: Icons.contacts),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 	AppLocalizations.of(context).translate("String21"),
                        icon: Icons.send),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 	AppLocalizations.of(context).translate("String94"),
                        icon: Icons.remove_red_eye),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 	AppLocalizations.of(context).translate("String30"),
                        icon: Icons.settings),
                  ]
                : [
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 'History',
                        icon: Icons.history),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 'Contacts',
                        icon: Icons.contacts),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 'Transfer',
                        icon: Icons.send),
                    TitledNavigationBarItem(
                        backgroundColor: ColorTheme.of(context).baseColor,
                        title: 'Settings',
                        icon: Icons.settings),
                  ]),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    child: Opacity(
                        opacity: pageIndex == 0 ? 1.0 : 0.0,
                        child: IgnorePointer(
                            child: tranSactionsWidgetInstance,
                            ignoring: pageIndex != 0)),
                  ),
                  Positioned(
                    child: Opacity(
                        opacity: pageIndex == 1 ? 1.0 : 0.0,
                        child: IgnorePointer(
                            child: contactsWindow, ignoring: pageIndex != 1)),
                  ),
                  Positioned(
                    child: Opacity(
                        opacity: pageIndex == 2 ? 1.0 : 0.0,
                        child: IgnorePointer(
                            child: sendWindowInstance,
                            ignoring: pageIndex != 2)),
                  ),
                  Positioned(
                    child: Opacity(
                        opacity: sentinels
                            ? pageIndex == 4 ? 1.0 : 0.0
                            : pageIndex == 3 ? 1.0 : 0.0,
                        child: IgnorePointer(
                            child: settingsWindow,
                            ignoring:
                                sentinels ? pageIndex != 4 : pageIndex != 3)),
                  ),
                  Positioned(
                    child: Opacity(
                        opacity: sentinels
                            ? pageIndex == 3 ? 1.0 : 0.0
                            : pageIndex == 4 ? 1.0 : 0.0,
                        child: IgnorePointer(
                            child: verifiersWindow,
                            ignoring:
                                sentinels ? pageIndex != 3 : pageIndex != 4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
