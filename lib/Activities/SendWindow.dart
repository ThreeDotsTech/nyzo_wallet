import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nyzo_wallet/Activities/QRCamera.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_picker/flutter_picker.dart';

class SendWindow extends StatefulWidget {
  SendWindow(this.password, this.address);
  final String password;
  final String address;
  @override
  _SendWindowState createState() => _SendWindowState(password, address);
}

class _SendWindowState extends State<SendWindow> with WidgetsBindingObserver {
  _SendWindowState(this.password, this.address);

  List<Contact> contactsList;
  final String password;
  final String address;
  bool sendRECEIVE = false;
  FocusNode focusNodeAmount = FocusNode();
  FocusNode focusNodeAddress = FocusNode();
  FocusNode focusNodeData = FocusNode();
  bool isKeyboardOpen = false;
  WalletWindowState walletWindowState;
  bool _isLoading = false;
  @override
  void didChangeMetrics() {
    final value = WidgetsBinding.instance.window.viewInsets.bottom;

    if (value > 0) {
      if (isKeyboardOpen) {
        _onKeyboardChanged(false);
      }
      isKeyboardOpen = false;
    } else {
      isKeyboardOpen = true;
      _onKeyboardChanged(true);
    }
  }

  _onKeyboardChanged(bool isHidden) {
    if (isHidden) {
      FocusScope.of(context).unfocus();
    } else {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    walletWindowState = context.findAncestorStateOfType<WalletWindowState>();
    getContacts().then((List<Contact> _contactList) {
      setState(() {
        contactsList = _contactList;
      });
    });
    WidgetsBinding.instance.addObserver(this);
    focusNodeAddress.addListener(() {
      setState(() {
        quitFocus();
      });
    });
    focusNodeAmount.addListener(() {
      setState(() {
        quitFocus();
      });
    });
    focusNodeData.addListener(() {
      setState(() {
        quitFocus();
      });
    });
    super.initState();
  }

  void quitFocus() {
    if (!focusNodeAmount.hasFocus &&
        !focusNodeAddress.hasFocus &&
        !focusNodeData.hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  showPickerDialog(BuildContext context, List<Contact> contacts) {
    List<PickerItem<String>> pickerItemList = [];
    for (var contact in contacts) {
      pickerItemList
          .add(PickerItem(text: Text(contact.name), value: contact.address));
    }
    new Picker(
        adapter: PickerDataAdapter<String>(data: pickerItemList),
        hideHeader: true,
        title: new Text(AppLocalizations.of(context).translate("String20")),
        onConfirm: (Picker picker, List value) {
          if (picker.getSelectedValues().length != 0) {
            walletWindowState.textControllerAddress.text =
                picker.getSelectedValues()[0];
          }
        }).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                !focusNodeAmount.hasFocus &&
                        !focusNodeAddress.hasFocus &&
                        !focusNodeData.hasFocus
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context).translate("String21"),
                          style: TextStyle(
                              color: ColorTheme.of(context).secondaryColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              fontSize: 35),
                        ),
                      )
                    : Container(),
                Expanded(
                  flex: 5,
                  child: Container(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: RaisedButton(
                            color: ColorTheme.of(context).baseColor,
                            elevation: 0,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(
                                    color: !sendRECEIVE
                                        ? Color(0xFF666666)
                                        : ColorTheme.of(context).baseColor),
                                borderRadius: new BorderRadius.circular(100.0)),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: Text(
                                    AppLocalizations.of(context)
                                        .translate("String22"),
                                    style: TextStyle(
                                        color: !sendRECEIVE
                                            ? ColorTheme.of(context)
                                                .secondaryColor
                                            : Color(0xFF666666)))),
                            onPressed: () {
                              setState(() {
                                sendRECEIVE = false;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: RaisedButton(
                            color: ColorTheme.of(context).baseColor,
                            elevation: 0,
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(
                                    color: sendRECEIVE
                                        ? Color(0xFF666666)
                                        : ColorTheme.of(context).baseColor),
                                borderRadius: new BorderRadius.circular(100.0)),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("String23"),
                                  style: TextStyle(
                                      color: sendRECEIVE
                                          ? ColorTheme.of(context)
                                              .secondaryColor
                                          : Color(0xFF666666)),
                                )),
                            onPressed: () {
                              setState(() {
                                sendRECEIVE = true;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
                sendRECEIVE
                    ? Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 1, 0, 12),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("String24"),
                                    style: TextStyle(
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.1,
                                right: MediaQuery.of(context).size.width * 0.1,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: RaisedButton(
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        onPressed: () {
                                          Clipboard.setData(
                                              new ClipboardData(text: address));
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  AppLocalizations.of(context)
                                                      .translate("String25")));
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        },
                                        child: RichText(
                                          overflow: TextOverflow.fade,
                                          maxLines: 3,
                                          textAlign: TextAlign.justify,
                                          text: TextSpan(
                                            style: TextStyle(
                                                color: ColorTheme.of(context)
                                                    .baseColor,
                                                fontWeight: FontWeight.w500),
                                            text: address,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.22,
                                right: MediaQuery.of(context).size.width * 0.22,
                              ),
                              child: QrImage(
                                foregroundColor:
                                    ColorTheme.of(context).secondaryColor,
                                data: address,
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                  child: Text(
                                    "Nyzo",
                                    style: TextStyle(
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.075,
                                right:
                                    MediaQuery.of(context).size.width * 0.075,
                              ),
                              child: TextFormField(
                                maxLengthEnforced: false,
                                focusNode: focusNodeAmount,
                                key: walletWindowState.amountFormKey,
                                controller:
                                    walletWindowState.textControllerAmount,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                scrollPadding: EdgeInsets.all(00),
                                validator: (String val) => walletWindowState
                                            .textControllerAmount.text ==
                                        ""
                                    ? AppLocalizations.of(context)
                                        .translate("String67")
                                    : double.tryParse(walletWindowState.textControllerAmount.text) ==
                                            null
                                        ? AppLocalizations.of(context)
                                            .translate("String89")
                                        : double.tryParse(walletWindowState
                                                            .textControllerAmount
                                                            .text)
                                                        .toInt() *
                                                    1000000 >=
                                                walletWindowState.balance
                                            ? AppLocalizations.of(context)
                                                .translate("String90")
                                            : null,
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context).secondaryColor),
                                decoration: InputDecoration(
                                  suffixIcon: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100))),
                                    color: Colors.transparent,
                                    elevation: 0,
                                    onPressed: () {
                                      walletWindowState
                                              .textControllerAmount.text =
                                          (walletWindowState.balance / 1000000)
                                              .toString();
                                    },
                                    child: Text(
                                      "MAX",
                                      style: TextStyle(
                                          color: ColorTheme.of(context)
                                              .secondaryColor),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: ColorTheme.of(context).dephtColor,
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                  contentPadding: EdgeInsets.all(10),
                                  hasFloatingPlaceholder: false,
                                  labelText: AppLocalizations.of(context)
                                      .translate("String91"),
                                  labelStyle: TextStyle(
                                      color: Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("String26"),
                                    style: TextStyle(
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.075,
                                right:
                                    MediaQuery.of(context).size.width * 0.075,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                autovalidate: true,
                                focusNode: focusNodeAddress,
                                key: walletWindowState.addressFormKey,
                                controller:
                                    walletWindowState.textControllerAddress,
                                validator: (String val) {
                                  if (val != "") {
                                    if (val == address) {
                                      return 'This is your own address!';
                                    }
                                    try {
                                      NyzoStringEncoder.decode(val);
                                      if (NyzoStringEncoder.decode(val)
                                              .getType()
                                              .getPrefix() ==
                                          'pre_') {
                                        NyzoStringPrefilledData pre =
                                            NyzoStringPrefilledData
                                                .fromByteBuffer(
                                                    NyzoStringEncoder.decode(
                                                            val)
                                                        .getBytes()
                                                        .buffer);
                                        //setState(() {
                                        walletWindowState
                                                .textControllerAddress.text =
                                            NyzoStringEncoder.encode(
                                                NyzoStringPublicIdentifier(pre
                                                    .getReceiverIdentifier()));

                                        walletWindowState
                                                .textControllerData.text =
                                            utf8.decode(pre.getSenderData());
                                      }
                                    } catch (e) {
                                      return InvalisNyzoString().errMsg();
                                    }
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context).secondaryColor),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: ColorTheme.of(context).dephtColor,
                                  contentPadding: EdgeInsets.all(10),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Image.asset(
                                          "images/qr.png",
                                          color: ColorTheme.of(context)
                                              .secondaryColor,
                                        ),
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          WalletWindowState walletWindowState =
                                              context.ancestorStateOfType(
                                                  TypeMatcher<
                                                      WalletWindowState>());

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    QrCameraWindow(
                                                        walletWindowState)),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        icon: Icon(Icons.contacts),
                                        onPressed: () {
                                          getContacts().then(
                                              (List<Contact> _contactList) {
                                            setState(() {
                                              contactsList = _contactList;
                                            });
                                            showPickerDialog(
                                                context, contactsList);
                                            FocusScope.of(context).unfocus();
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  hasFloatingPlaceholder: false,
                                  labelText: AppLocalizations.of(context)
                                      .translate("String92"),
                                  labelStyle: TextStyle(
                                      color: Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("String27"),
                                    style: TextStyle(
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.075,
                                right:
                                    MediaQuery.of(context).size.width * 0.075,
                              ),
                              child: TextFormField(
                                focusNode: focusNodeData,
                                key: walletWindowState.dataFormKey,
                                controller:
                                    walletWindowState.textControllerData,
                                maxLength: 32,
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context).secondaryColor),
                                decoration: InputDecoration(
                                  counterStyle: TextStyle(
                                      color: ColorTheme.of(context)
                                          .secondaryColor),
                                  filled: true,
                                  fillColor: ColorTheme.of(context).dephtColor,
                                  contentPadding: EdgeInsets.all(10),
                                  hasFloatingPlaceholder: false,
                                  labelText: AppLocalizations.of(context)
                                      .translate("String93"),
                                  labelStyle: TextStyle(
                                      color: Color(0xFF555555),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Color(0x55666666))),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide:
                                          BorderSide(color: Colors.red)),
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.15,
                                      right: MediaQuery.of(context).size.width *
                                          0.15,
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: RaisedButton(
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                        color: ColorTheme.of(context)
                                            .secondaryColor,
                                        textColor:
                                            ColorTheme.of(context).baseColor,
                                        child: Text(AppLocalizations.of(context)
                                            .translate("String22")),
                                        onPressed: () {
                                          //var dataForm = dataFormKey.currentState;
                                          var addressForm = walletWindowState
                                              .addressFormKey.currentState;
                                          var amountForm = walletWindowState
                                              .amountFormKey.currentState;
                                          if (addressForm.validate() &&
                                              amountForm.validate()) {
                                            var address = walletWindowState
                                                .textControllerAddress.text;
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            send(
                                                    password,
                                                    address,
                                                    (double.parse(walletWindowState
                                                                .textControllerAmount
                                                                .text) *
                                                            1000000)
                                                        .toInt(),
                                                    walletWindowState.balance,
                                                    walletWindowState
                                                        .textControllerData
                                                        .text)
                                                .then((String result) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              return showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              "String28"),
                                                      style: TextStyle(
                                                          color: ColorTheme.of(
                                                                  context)
                                                              .secondaryColor),
                                                    ),
                                                    content: Text(result),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "String29")),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            });
                                            walletWindowState
                                                .textControllerAddress
                                                .clear();
                                            walletWindowState
                                                .textControllerAmount
                                                .clear();
                                            walletWindowState.textControllerData
                                                .clear();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
              ],
            ),
          ),
          _isLoading
              ? Positioned(
                  child: new Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new ClipOval(
                          child: new BackdropFilter(
                            filter: new ImageFilter.blur(
                                sigmaX: 100.0, sigmaY: 100.0),
                            child: new Container(
                              width: 200.0,
                              height: 200.0,
                              decoration: new BoxDecoration(
                                  color: Colors.grey.shade200.withOpacity(0)),
                              child: new Center(
                                child: SpinKitChasingDots(
                                  color: ColorTheme.of(context).secondaryColor,
                                  size: 50.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
