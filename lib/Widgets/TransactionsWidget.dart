// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/MyTokensListWindow.dart';
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/Transaction.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';
import 'package:nyzo_wallet/Widgets/SheetUtil.dart';

class TransactionsWidget extends StatefulWidget {
  final List<Transaction>? _transactions;
  const TransactionsWidget(this._transactions);
  @override
  TranSactionsWidgetState createState() =>
      TranSactionsWidgetState(_transactions!);
}

class TranSactionsWidgetState extends State<TransactionsWidget> {
  List<Transaction> _transactions;
  TranSactionsWidgetState(this._transactions);
  String _address = '';
  List<Contact>? _contactsList;
  WalletWindowState? walletWindowState;
  final SlidableController slidableController = SlidableController();

  @override
  void initState() {
    walletWindowState = context.findAncestorStateOfType<WalletWindowState>()!;
    getAddress().then((address) {
      _address = address;
      getTransactions(_address).then((List<Transaction> transactions) {
        setState(() {
          _transactions = transactions;
        });
      });
    });
    getContacts().then((List<Contact> contacts) {
      _contactsList = contacts;
    });
    super.initState();
  }

  Future<void> refresh() async {
    final WalletWindowState? walletWindowState =
        context.findAncestorStateOfType<WalletWindowState>();
    final Future transactions = getTransactions(_address);
    getBalance(_address).then((double _balance) {
      walletWindowState!.setState(() {
        walletWindowState.balance = _balance.floor();
        setSavedBalance(_balance);
      });
    });
    transactions.then((transactionsList) {
      setState(() {
        _transactions = transactionsList;
      });
      //getBalance(_address).then((int balance){});
    });
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Center(
            child: Text(
              AppLocalizations.of(context)!.translate('String72'),
              style: TextStyle(
                  color: ColorTheme.of(context)!.secondaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  fontSize: 35),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.translate('String50'),
                      style: const TextStyle(
                          color: const Color(0xFF555555), fontSize: 15),
                    ),
                    RichText(
                      text: TextSpan(
                        text: walletWindowState!.balance == 0
                            ? walletWindowState!.balance.toString()
                            : (walletWindowState!.balance / 1000000).toString(),
                        style: TextStyle(
                            color: ColorTheme.of(context)!.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 40),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ∩',
                            style: TextStyle(
                                color: ColorTheme.of(context)!.secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                walletWindowState!.myTokensList.length > 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [BoxShadow(color: Colors.transparent)],
                            ),
                            height: 35,
                            margin: EdgeInsetsDirectional.only(
                                start: 7, top: 0.0, end: 7.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    ColorTheme.of(context)!.secondaryColor,
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                              ),
                              child: Icon(Icons.scatter_plot_rounded,
                                  color: ColorTheme.of(context)!.baseColor,
                                  size: 20),
                              onPressed: () {
                                Sheets.showAppHeightEightSheet(
                                    color: ColorTheme.of(context)!.depthColor,
                                    context: context,
                                    widget: MyTokensListWindow(
                                        walletWindowState!.myTokensList));
                              },
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('String102'),
                            style: TextStyle(
                                color: const Color(0xFF555555),
                                letterSpacing: 0,
                                fontSize: 15),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          const Divider(
            color: const Color(0xFF555555),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
            child: Text(
              AppLocalizations.of(context)!.translate('String73'),
              style: const TextStyle(color: Color(0xFF555555), fontSize: 15),
            ),
          ),
          Container(
            height: walletWindowState!.screenHeight! / 2,
            child: _transactions != null
                ? _transactions.isEmpty
                    ? Center(
                        child: InkWell(
                          onTap: () {
                            refresh();
                          },
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/noTransactions.png',
                                  color: ColorTheme.of(context)!.secondaryColor,
                                  height: walletWindowState!.screenHeight! / 5,
                                  //width: walletWindowState.screenHeight / 5 * 0.9,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('String78'),
                                      style: TextStyle(
                                          color: ColorTheme.of(context)!
                                              .secondaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('String79'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : LiquidPullToRefresh(
                        color: const Color(0xFF403942),
                        height: 75,
                        showChildOpacityTransition: false,
                        springAnimationDurationInMilliseconds: 250,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(0.0),
                            itemCount: _transactions.length,
                            itemBuilder: (context, i) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    children: <Widget>[
                                      Slidable(
                                        controller: slidableController,
                                        actionPane:
                                            const SlidableDrawerActionPane(),
                                        actions: <Widget>[
                                          IconSlideAction(
                                            caption: 'Send',
                                            color: ColorTheme.of(context)!
                                                .baseColor,
                                            icon: Icons.send,
                                            onTap: () {
                                              walletWindowState!
                                                      .textControllerAddress
                                                      .text =
                                                  _transactions[i].address!;
                                              walletWindowState!.setState(() {
                                                walletWindowState!.pageIndex =
                                                    2;
                                              });
                                            },
                                          )
                                        ],
                                        child: ExpandablePanel(
                                          collapsed: ListTile(
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                border: Border.all(
                                                  width: 1.0,
                                                  color:
                                                      const Color(0xFF555555),
                                                ),
                                              ),
                                              child: _transactions[i].type ==
                                                      'from'
                                                  ? const Icon(
                                                      Icons.add,
                                                      color: Color(0xFF555555),
                                                    )
                                                  : const Icon(
                                                      Icons.remove,
                                                      color: Color(0xFF555555),
                                                    ),
                                            ),
                                            title: InkWell(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: _transactions[i]
                                                        .address));
                                                final snackbar = SnackBar(
                                                    content: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .translate(
                                                                'String25')));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackbar);
                                              },
                                              child: Text(
                                                _contactsList!
                                                        .any((Contact contact) {
                                                  return contact.address ==
                                                      _transactions[i].address;
                                                })
                                                    ? _contactsList!.firstWhere(
                                                        (Contact contact) {
                                                        return contact
                                                                .address ==
                                                            _transactions[i]
                                                                .address;
                                                      }).name
                                                    : _transactions[i]
                                                            .address!
                                                            .substring(0, 4) +
                                                        '...' +
                                                        _transactions[i]
                                                            .address!
                                                            .substring(
                                                                _transactions[i]
                                                                        .address!
                                                                        .length -
                                                                    4),
                                                style: TextStyle(
                                                    color:
                                                        ColorTheme.of(context)!
                                                            .secondaryColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            trailing: Text(
                                              _transactions[i]
                                                      .amount
                                                      .toString() +
                                                  ' ∩',
                                              style: TextStyle(
                                                  color: ColorTheme.of(context)!
                                                      .secondaryColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          expanded: Column(
                                            children: <Widget>[
                                              ListTile(
                                                leading: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    border: Border.all(
                                                      width: 1.0,
                                                      color: const Color(
                                                          0xFF555555),
                                                    ),
                                                  ),
                                                  child: _transactions[i]
                                                              .type ==
                                                          'from'
                                                      ? Icon(
                                                          Icons.add,
                                                          color:
                                                              Colors.green[200],
                                                        )
                                                      : Icon(
                                                          Icons.remove,
                                                          color:
                                                              Colors.red[200],
                                                        ),
                                                ),
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: _transactions[
                                                                        i]
                                                                    .address));
                                                        final snackbar = SnackBar(
                                                            content: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'String25')));
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                snackbar);
                                                      },
                                                      child: Text(
                                                        _transactions[i]
                                                            .address!,
                                                        style: TextStyle(
                                                            color: ColorTheme.of(
                                                                    context)!
                                                                .secondaryColor,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 4.0),
                                                      child: AutoSizeText(
                                                        'Block: ' +
                                                            _transactions[i]
                                                                .block!,
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: ColorTheme.of(
                                                                    context)!
                                                                .secondaryColor),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                trailing: Text(
                                                  _transactions[i]
                                                          .amount!
                                                          .toStringAsFixed(_transactions[
                                                                          i]
                                                                      .amount!
                                                                      .truncateToDouble() ==
                                                                  _transactions[
                                                                          i]
                                                                      .amount
                                                              ? 0
                                                              : 2) +
                                                      ' ∩',
                                                  style: TextStyle(
                                                      color: ColorTheme.of(
                                                              context)!
                                                          .secondaryColor,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: ColorTheme.of(context)!
                                            .highLigthColor,
                                        indent: 0,
                                        height: 0,
                                      )
                                    ],
                                  ),
                                )),
                        onRefresh: () {
                          return refresh();
                        },
                      )
                : ListView.builder(
                    padding: const EdgeInsets.all(0.0),
                    itemCount: 8,
                    itemBuilder: (context, i) => Card(
                        color: ColorTheme.of(context)!.baseColor,
                        child: SizedBox(
                          width: 200.0,
                          height: 60.0,
                          child: Shimmer.fromColors(
                            baseColor:
                                ColorTheme.of(context)!.transparentColor!,
                            highlightColor:
                                ColorTheme.of(context)!.highLigthColor!,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ListTile(
                                leading: Container(
                                  color: Colors.green,
                                  width: 50,
                                  height: 50,
                                ),
                                title: const Text(
                                    '                                                                        ',
                                    style: TextStyle(
                                        backgroundColor: Colors.grey)),
                              ),
                            ),
                          ),
                        ))),
          ),
        ],
      ),
    );
  }

  String splitJoinString(String address) {
    final String val = address.split('-').join('');
    return val;
  }
}
