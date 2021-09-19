// Dart imports:
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/TransactionsSinceResponse.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class TransactionsDetailsWidget {
  static Widget buildTransactionsDisplay(
      BuildContext context,
      String address,
      WalletWindowState walletWindowState,
      List<Tx>? _transactions,
      List<Contact>? _contactsList,
      Function refresh) {
    final SlidableController slidableController = SlidableController();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
          child: Text(
            AppLocalizations.of(context)!.translate('String73'),
            style: const TextStyle(color: Color(0xFF555555), fontSize: 15),
          ),
        ),
        Container(
          height: walletWindowState.screenHeight! / 2,
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
                                height: walletWindowState.screenHeight! / 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
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
                          itemBuilder: (BuildContext context, int i) => Padding(
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
                                          color:
                                              ColorTheme.of(context)!.baseColor,
                                          icon: Icons.send,
                                          onTap: () {
                                            walletWindowState
                                                    .textControllerAddress
                                                    .text =
                                                NyzoStringEncoder.encode(
                                                    NyzoStringPublicIdentifier(
                                                        Uint8List.fromList(
                                                            utf8.encode(
                                                                _transactions[i]
                                                                    .sender!))));
                                            walletWindowState.setState(() {
                                              walletWindowState.pageIndex = 2;
                                            });
                                          },
                                        )
                                      ],
                                      child: ListTile(
                                        title: InkWell(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: NyzoStringEncoder.encode(
                                                      NyzoStringPublicIdentifier(
                                                          Uint8List.fromList(
                                                              utf8.encode(
                                                                  _transactions[
                                                                          i]
                                                                      .sender!))))));
                                              final SnackBar snackbar =
                                                  SnackBar(
                                                      content: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .translate(
                                                                  'String25')));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      getTypeTxIcon(
                                                          _transactions[i]
                                                              .data!,
                                                          address,
                                                          _transactions[i]
                                                              .sender!),
                                                    ]),
                                                const SizedBox(
                                                  width: 40,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      DateFormat.yMEd(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .locale
                                                                  .languageCode)
                                                          .add_Hms()
                                                          .format(DateTime.fromMillisecondsSinceEpoch(
                                                                  _transactions[
                                                                          i]
                                                                      .timestamp!)
                                                              .toLocal())
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: ColorTheme.of(
                                                                  context)!
                                                              .secondaryColor,
                                                          fontSize: 13),
                                                    ),
                                                    if (_transactions[i]
                                                            .amountAfterFees! >
                                                        0)
                                                      Text(
                                                        (getAmount(
                                                              _transactions[i]
                                                                  .amountAfterFees!,
                                                            )!)
                                                                .toString() +
                                                            ' ∩',
                                                        style: _transactions[i].sender ==
                                                                address
                                                            ? TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 20,
                                                                foreground:
                                                                    Paint()
                                                                      ..shader = ui.Gradient.linear(
                                                                          Offset.zero,
                                                                          const Offset(0, 60),
                                                                          [
                                                                            Colors.red[100]!,
                                                                            Colors.red[900]!
                                                                          ]))
                                                            : TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 20,
                                                                foreground:
                                                                    Paint()
                                                                      ..shader = ui.Gradient.linear(
                                                                          Offset.zero,
                                                                          const Offset(0, 60),
                                                                          [
                                                                            Colors.green[100]!,
                                                                            Colors.green[900]!
                                                                          ])),
                                                      )
                                                    else
                                                      const SizedBox(),
                                                    if (isToken(
                                                        _transactions[i].data!))
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            (getAmountToken(_transactions[
                                                                            i]
                                                                        .data!)!)
                                                                    .toString() +
                                                                ' ' +
                                                                getSenderDataName(
                                                                    _transactions[
                                                                            i]
                                                                        .data!),
                                                            style: _transactions[i].sender == address
                                                                ? TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        20,
                                                                    foreground: Paint()
                                                                      ..shader = ui.Gradient.linear(
                                                                          Offset.zero,
                                                                          const Offset(0, 60),
                                                                          [
                                                                            Colors.red[100]!,
                                                                            Colors.red[900]!
                                                                          ]))
                                                                : TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        20,
                                                                    foreground: Paint()
                                                                      ..shader = ui.Gradient.linear(
                                                                          Offset.zero,
                                                                          const Offset(0, 60),
                                                                          [
                                                                            Colors.green[100]!,
                                                                            Colors.green[900]!
                                                                          ])),
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      isNFT(_transactions[i]
                                                              .data!)
                                                          ? Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  getSenderDataName(
                                                                      _transactions[
                                                                              i]
                                                                          .data!),
                                                                  style: _transactions[i].sender ==
                                                                          address
                                                                      ? TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              20,
                                                                          foreground: Paint()
                                                                            ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 60), [
                                                                              Colors.red[100]!,
                                                                              Colors.red[900]!
                                                                            ]))
                                                                      : TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              20,
                                                                          foreground: Paint()
                                                                            ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 60), [
                                                                              Colors.green[100]!,
                                                                              Colors.green[900]!
                                                                            ])),
                                                                ),
                                                                Text(
                                                                  (' (' + getUID(_transactions[i].data!)!)
                                                                          .toString() +
                                                                      ')',
                                                                  style: _transactions[i].sender ==
                                                                          address
                                                                      ? TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              13,
                                                                          foreground: Paint()
                                                                            ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 60), [
                                                                              Colors.red[100]!,
                                                                              Colors.red[900]!
                                                                            ]))
                                                                      : TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              13,
                                                                          foreground: Paint()
                                                                            ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 60), [
                                                                              Colors.green[100]!,
                                                                              Colors.green[900]!
                                                                            ])),
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                    Row(
                                                      children: <Widget>[
                                                        if (_transactions[i]
                                                                .sender! ==
                                                            address)
                                                          Text('To: ',
                                                              style: TextStyle(
                                                                  color: ColorTheme.of(
                                                                          context)!
                                                                      .secondaryColor,
                                                                  fontSize: 15))
                                                        else
                                                          Text('From: ',
                                                              style: TextStyle(
                                                                  color: ColorTheme.of(
                                                                          context)!
                                                                      .secondaryColor,
                                                                  fontSize:
                                                                      15)),
                                                        Text(
                                                          _contactsList!.any(
                                                                  (Contact
                                                                      contact) {
                                                            return contact
                                                                    .address ==
                                                                NyzoStringEncoder.encode(
                                                                    NyzoStringPublicIdentifier(
                                                                        Uint8List.fromList(
                                                                            utf8.encode(_transactions[i].sender!))));
                                                          })
                                                              ? _contactsList
                                                                  .firstWhere(
                                                                      (Contact
                                                                          contact) {
                                                                  return contact
                                                                          .address ==
                                                                      NyzoStringEncoder
                                                                          .encode(
                                                                              NyzoStringPublicIdentifier(Uint8List.fromList(utf8.encode(_transactions[i].sender!))));
                                                                }).name
                                                              : getIdFromAddress(
                                                                  _transactions[
                                                                          i]
                                                                      .sender!),
                                                          style: TextStyle(
                                                              color: ColorTheme.of(
                                                                      context)!
                                                                  .secondaryColor,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      isToken(_transactions[i]
                                                                  .data!) ||
                                                              isNFT(
                                                                  _transactions[
                                                                          i]
                                                                      .data!)
                                                          ? getSenderDataComment(
                                                              _transactions[i]
                                                                  .data!)
                                                          : _transactions[i]
                                                              .data!,
                                                      style: TextStyle(
                                                          color: ColorTheme.of(
                                                                  context)!
                                                              .secondaryColor,
                                                          fontSize: 11),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )),
                                        dense: true,
                                        subtitle: const Divider(),
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
                  itemBuilder: (BuildContext context, int i) => Card(
                      color: ColorTheme.of(context)!.baseColor,
                      child: SizedBox(
                        width: 200.0,
                        height: 60.0,
                        child: Shimmer.fromColors(
                          baseColor: ColorTheme.of(context)!.transparentColor!,
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
                                  style:
                                      TextStyle(backgroundColor: Colors.grey)),
                            ),
                          ),
                        ),
                      ))),
        ),
      ],
    );
  }

  static String getIdFromAddress(String address) {
    final String _id = NyzoStringEncoder.encode(
        NyzoStringPublicIdentifier(Uint8List.fromList(utf8.encode(address))));
    return _id.substring(0, 6) + '...' + _id.substring(_id.length - 10);
  }

  static bool isToken(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.isNotEmpty &&
        infos[0].length == 2 &&
        (infos[0].startsWith('T'))) {
      return true;
    } else {
      return false;
    }
  }

  static bool isNFT(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.isNotEmpty &&
        infos[0].length == 2 &&
        (infos[0].startsWith('N'))) {
      return true;
    } else {
      return false;
    }
  }

  static String typeTx(String senderData, BuildContext context) {
    final List<String> infos = senderData.split(':');
    if (infos.isNotEmpty) {
      switch (infos[0]) {
        case 'TT':
          return AppLocalizations.of(context)!.translate('String111');
        case 'TI':
          return AppLocalizations.of(context)!.translate('String112');
        case 'TM':
          return AppLocalizations.of(context)!.translate('String113');
        case 'TB':
          return AppLocalizations.of(context)!.translate('String114');
        case 'TO':
          return AppLocalizations.of(context)!.translate('String115');
        case 'NT':
          return AppLocalizations.of(context)!.translate('String111');
        case 'NI':
          return AppLocalizations.of(context)!.translate('String112');
        case 'NM':
          return AppLocalizations.of(context)!.translate('String113');
        case 'NB':
          return AppLocalizations.of(context)!.translate('String114');
        case 'NO':
          return AppLocalizations.of(context)!.translate('String116');
        case 'NA':
          return AppLocalizations.of(context)!.translate('String117');
        case 'ND':
          return AppLocalizations.of(context)!.translate('String118');
        default:
          return AppLocalizations.of(context)!.translate('String111');
      }
    } else {
      return AppLocalizations.of(context)!.translate('String25');
    }
  }

  static Icon getTypeTxIcon(
      String senderData, String address, String transactionSender) {
    final List<String> infos = senderData.split(':');
    if (infos.isNotEmpty) {
      switch (infos[0]) {
        case 'TT':
          if (transactionSender != address) {
            return const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          } else {
            return const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          }
        case 'TI':
          return const Icon(
            Icons.build,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'TM':
          return const Icon(
            RpgAwesome.mining_diamonds,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'TB':
          return const Icon(
            RpgAwesome.burning_embers,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'TO':
          return const Icon(
            Entypo.switch_icon,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'NT':
          if (transactionSender != address) {
            return const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          } else {
            return const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          }
        case 'NI':
          return const Icon(
            Icons.build,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'NM':
          return const Icon(
            RpgAwesome.mining_diamonds,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'NB':
          return const Icon(
            RpgAwesome.burning_embers,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'NO':
          return const Icon(
            Entypo.switch_icon,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'NA':
          return const Icon(
            Entypo.database,
            color: Color(0xFF555555),
            size: 20,
          );
        case 'ND':
          return const Icon(
            Entypo.database,
            color: Color(0xFF555555),
            size: 20,
          );
        default:
          if (transactionSender != address) {
            return const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          } else {
            return const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFF555555),
              size: 20,
            );
          }
      }
    } else {
      if (transactionSender != address) {
        return const Icon(
          Icons.add_circle_outline,
          color: Color(0xFF555555),
          size: 20,
        );
      } else {
        return const Icon(
          Icons.remove_circle_outline,
          color: Color(0xFF555555),
          size: 20,
        );
      }
    }
  }

  static String getSenderDataName(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.length > 1) {
      return infos[1];
    } else {
      return senderData;
    }
  }

  static String getSenderDataComment(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.length > 1) {
      int commentIndex = 3;
      if (infos[0].startsWith('N')) {
        commentIndex = 4;
      }
      if (infos.length > commentIndex) {
        if (infos[commentIndex] != '-1') {
          return infos[commentIndex];
        } else {
          return '';
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  static double? getAmount(int amount) {
    return double.tryParse((amount.toDouble() / 1000000).toStringAsFixed(6));
  }

  static double? getAmountToken(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.length > 2) {
      return double.tryParse(double.tryParse(infos[2])!.toStringAsFixed(6));
    } else {
      return 0;
    }
  }

  static String? getUID(String senderData) {
    final List<String> infos = senderData.split(':');
    if (infos.length > 2) {
      return infos[2];
    } else {
      return 'UID Unknown';
    }
  }
}
