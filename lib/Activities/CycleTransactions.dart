// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Project imports:
import 'package:nyzo_wallet/Data/CycleTransaction.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class CycleTxScreen extends StatefulWidget {
  const CycleTxScreen(this.password);
  final String password;
  @override
  _CycleTxScreenState createState() => _CycleTxScreenState(password);
}

DirectSelectItem<CycleTransaction> getDropDownMenuItem(CycleTransaction value) {
  return DirectSelectItem<CycleTransaction>(
      itemHeight: 56,
      value: value,
      itemBuilder: (BuildContext context, CycleTransaction value) {
        if (value.receiverNickname == null) {
          return Text(value.receiverId!.substring(0, 3) +
              '...' +
              value.receiverId!.substring(
                  value.receiverId!.length - 4, value.receiverId!.length));
        }
        return Text(value.receiverNickname!);
      });
}

BoxDecoration _getShadowDecoration() {
  return BoxDecoration(
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        spreadRadius: 4,
        offset: const Offset(0.0, 0.0),
        blurRadius: 15.0,
      ),
    ],
  );
}

class _CycleTxScreenState extends State<CycleTxScreen> {
  TextEditingController textEditingController = TextEditingController();
  _CycleTxScreenState(this._password);
  final String _password;
  List<CycleTransaction>? txList;
  CycleTransaction? currentTx;
  bool _loading = true;
  int selectedIndex = 0;
  @override
  void initState() {
    getCycleTransactions().then((List<CycleTransaction> list) {
      setState(() {
        _loading = false;
        txList = list;
        if (txList != null) {
          if (txList!.isNotEmpty) {
            currentTx = txList![0];
          }
        }
      });
    });
    super.initState();
  }

  Icon _getDropdownIcon() {
    return const Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );
  }

  BoxDecoration _getDslDecoration() {
    return const BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }

  Padding _getRow(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              text1,
              style: TextStyle(
                  color: ColorTheme.of(context)!.secondaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
              child: Text(
            text2,
            style: TextStyle(color: ColorTheme.of(context)!.secondaryColor),
            textAlign: TextAlign.right,
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ColorTheme.of(context)!.lightTheme!) {
      setState(() {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      });
    }
    return DirectSelectContainer(
      child: Scaffold(
        backgroundColor: ColorTheme.of(context)!.baseColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.of(context)!.secondaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: txList != null
                  ? txList!.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Cycle TX',
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    fontSize: 35),
                              ),
                            ),
                            Container(
                              decoration: _getShadowDecoration(),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 22),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child:
                                            DirectSelectList<CycleTransaction>(
                                          onItemSelectedListener:
                                              (CycleTransaction cycleTx,
                                                  int index,
                                                  BuildContext buildContext) {
                                            setState(() {
                                              currentTx = cycleTx;
                                              selectedIndex = index;
                                            });
                                          },
                                          defaultItemIndex: selectedIndex,
                                          values: txList!,
                                          itemBuilder: (CycleTransaction tx) =>
                                              getDropDownMenuItem(tx),
                                          focusedItemDecoration:
                                              _getDslDecoration(),
                                        ),
                                      ),
                                      _getDropdownIcon()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: ColorTheme.of(context)!.depthColor,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: <Widget>[
                                    _getRow('initiator nickname',
                                        currentTx!.initiatorNickname!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('initiator ID',
                                        currentTx!.initiatorIdAsNyzoString!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('amount', currentTx!.ammount!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('receiver nickname',
                                        currentTx!.receiverNickname!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('receiver ID',
                                        currentTx!.receiverIdAsNyzoString!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow(
                                        'sender data', currentTx!.senderData!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('initiator signature',
                                        currentTx!.initiatorSignature!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow(
                                        'Total Votes', currentTx!.totalVotes!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('Votes Against',
                                        currentTx!.votesAgainst!),
                                    Divider(
                                      color: ColorTheme.of(context)!
                                          .highLigthColor,
                                      height: 0,
                                    ),
                                    _getRow('Votes for Tx',
                                        currentTx!.votesForTransaction!),
                                  ],
                                ),
                              ),
                            ),
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        ColorTheme.of(context)!.secondaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                  ),
                                  child: Text("Sign",
                                      style: TextStyle(
                                          color: ColorTheme.of(context)!
                                              .baseColor)),
                                  onPressed: () {
                                    setState(() {
                                      _loading = true;
                                    });
                                    signTransaction(
                                      currentTx!.initiatorSignature,
                                      currentTx!.initiatorId,
                                      currentTx!.bytes,
                                      password: _password,
                                    ).then((var json) {
                                      setState(() {
                                        _loading = false;
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .translate("String28"),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              content: Text(json["message"]),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(AppLocalizations
                                                          .of(context)!
                                                      .translate("String29")),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      });
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        ColorTheme.of(context)!.secondaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                  ),
                                  child: Text("Bulk Signing",
                                      style: TextStyle(
                                          color: ColorTheme.of(context)!
                                              .baseColor)),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext buildContext) {
                                          return AlertDialog(
                                            title: Text(
                                                "Enter Private keys to sign."),
                                            content: Container(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text("NyzoString or Raw."),
                                                  Text(
                                                    "Comma, Semicolon or space separated.",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w200),
                                                  ),
                                                  Container(
                                                    height: 400,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: TextFormField(
                                                      controller:
                                                          textEditingController,
                                                      expands: true,
                                                      minLines: null,
                                                      maxLines: null,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor:
                                                            ColorTheme.of(
                                                                    context)!
                                                                .depthColor,
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                        errorBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0x55666666))),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0x55666666))),
                                                        contentPadding:
                                                            EdgeInsets.all(10),
                                                        hasFloatingPlaceholder:
                                                            false,
                                                        labelText:
                                                            "Private keys",
                                                        labelStyle: TextStyle(
                                                            color: Color(
                                                                0xFF555555),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Sign"),
                                                onPressed: () {
                                                  /*
                                                  signTransactionWithKeyList(
                                                      textEditingController
                                                          .text,
                                                      currentTx!
                                                          .initiatorSignature,
                                                      currentTx!.initiatorId,
                                                      currentTx!.bytes);*/
                                                },
                                              )
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ],
                            )*/
                          ],
                        )
                      : Center(
                          child: Text(
                            'No TXs available',
                            style: TextStyle(
                                color: ColorTheme.of(context)!.secondaryColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                fontSize: 35),
                          ),
                        )
                  : Container(),
            ),
            if (_loading) Positioned(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (txList == null) Text(
                                  'Fetching TXs',
                                  style: TextStyle(
                                      color: ColorTheme.of(context)!
                                          .secondaryColor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                      fontSize: 35),
                                ) else Container(),
                          ClipOval(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 100.0),
                              child: Container(
                                width: 200.0,
                                height: 200.0,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200.withOpacity(0)),
                                child: Center(
                                  child: SpinKitChasingDots(
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
                                    size: 50.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) else Container(),
          ],
        ),
      ),
    );
  }
}
