// Dart imports:
import 'dart:convert';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/QRCamera.dart';
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/Token.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class SendWindow extends StatefulWidget {
  const SendWindow(
      {required this.password, required this.address, this.selectedTokenName});
  final String password;
  final String address;
  final String? selectedTokenName;
  @override
  _SendWindowState createState() =>
      _SendWindowState(password, address, selectedTokenName);
}

class _SendWindowState extends State<SendWindow> with WidgetsBindingObserver {
  _SendWindowState(this.password, this.address, this.selectedTokenName);

  List<Contact>? contactsList;
  final String password;
  final String address;
  final String? selectedTokenName;
  bool sendRECEIVE = false;
  FocusNode focusNodeAmount = FocusNode();
  FocusNode focusNodeAddress = FocusNode();
  FocusNode focusNodeData = FocusNode();
  FocusNode focusNodeTokenQuantity = FocusNode();
  FocusNode focusNodeTokenComments = FocusNode();
  bool isKeyboardOpen = false;
  WalletWindowState? walletWindowState;
  bool _isLoading = false;
  bool isTokenToSendSwitched = false;
  String _selectedTokenName = "";
  List<Token> myTokensList = List<Token>.empty(growable: true);

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    focusNodeAmount.dispose();
    focusNodeAddress.dispose();
    focusNodeData.dispose();
    focusNodeTokenComments.dispose();
    focusNodeTokenQuantity.dispose();
    super.dispose();
  }

  @override
  void initState() {
    walletWindowState = context.findAncestorStateOfType<WalletWindowState>()!;
    getContacts().then((List<Contact> _contactList) {
      setState(() {
        contactsList = _contactList;
      });
    });

    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  void showPickerDialog(BuildContext context, List<Contact> contacts) {
    final List<PickerItem<String>> pickerItemList = [];
    for (Contact contact in contacts) {
      pickerItemList
          .add(PickerItem(text: Text(contact.name), value: contact.address));
    }
    Picker(
        adapter: PickerDataAdapter<String>(data: pickerItemList),
        hideHeader: true,
        title: Text(AppLocalizations.of(context)!.translate('String20')),
        onConfirm: (Picker picker, List value) {
          if (picker.getSelectedValues().isNotEmpty) {
            walletWindowState!.textControllerAddress.text =
                picker.getSelectedValues()[0];
          }
        }).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 85,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate('String21'),
                    style: TextStyle(
                        color: ColorTheme.of(context)!.secondaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        fontSize: 35),
                  ),
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: ColorTheme.of(context)!.baseColor,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: !sendRECEIVE
                                            ? const Color(0xFF666666)
                                            : ColorTheme.of(context)!
                                                .baseColor!),
                                    borderRadius:
                                        BorderRadius.circular(100.0))),
                            child: Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('String22'),
                                    style: TextStyle(
                                        color: !sendRECEIVE
                                            ? ColorTheme.of(context)!
                                                .secondaryColor
                                            : const Color(0xFF666666)))),
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: ColorTheme.of(context)!.baseColor,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: !sendRECEIVE
                                            ? const Color(0xFF666666)
                                            : ColorTheme.of(context)!
                                                .baseColor!),
                                    borderRadius:
                                        BorderRadius.circular(100.0))),
                            child: Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('String23'),
                                  style: TextStyle(
                                      color: sendRECEIVE
                                          ? ColorTheme.of(context)!
                                              .secondaryColor
                                          : const Color(0xFF666666)),
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
                if (sendRECEIVE)
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 1, 0, 12),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('String24'),
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
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
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: ColorTheme.of(context)!
                                            .secondaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0))),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: address));
                                      final SnackBar snackBar = SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('String25')));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    child: RichText(
                                      overflow: TextOverflow.fade,
                                      maxLines: 3,
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                            color: ColorTheme.of(context)!
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
                                ColorTheme.of(context)!.secondaryColor,
                            data: address,
                          ),
                        )
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                    child: Text(
                                      'Nyzo',
                                      style: TextStyle(
                                          color: ColorTheme.of(context)!
                                              .secondaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.075,
                                  right:
                                      MediaQuery.of(context).size.width * 0.075,
                                ),
                                child: TextFormField(
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.none,
                                  focusNode: focusNodeAmount,
                                  key: walletWindowState!.amountFormKey,
                                  controller:
                                      walletWindowState!.textControllerAmount,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  maxLines: 1,
                                  scrollPadding: const EdgeInsets.all(00),
                                  validator: (String? val) =>
                                      walletWindowState!.textControllerAmount.text ==
                                              ''
                                          ? AppLocalizations.of(context)!
                                              .translate('String67')
                                          : double.tryParse(walletWindowState!
                                                      .textControllerAmount
                                                      .text) ==
                                                  null
                                              ? AppLocalizations.of(context)!
                                                  .translate('String89')
                                              : double.tryParse(walletWindowState!
                                                                  .textControllerAmount
                                                                  .text)!
                                                              .toInt() *
                                                          1000000 >=
                                                      walletWindowState!.balance
                                                  ? AppLocalizations.of(context)!
                                                      .translate('String90')
                                                  : null,
                                  style: TextStyle(
                                      color: ColorTheme.of(context)!
                                          .secondaryColor),
                                  decoration: InputDecoration(
                                    suffixIcon: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.transparent,
                                          elevation: 0,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100)))),
                                      onPressed: () {
                                        walletWindowState!
                                                .textControllerAmount.text =
                                            (walletWindowState!.balance /
                                                    1000000)
                                                .toString();
                                      },
                                      child: Text(
                                        'MAX',
                                        style: TextStyle(
                                            color: ColorTheme.of(context)!
                                                .secondaryColor),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        ColorTheme.of(context)!.depthColor,
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Color(0x55666666))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Color(0x55666666))),
                                    contentPadding: const EdgeInsets.all(10),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText: AppLocalizations.of(context)!
                                        .translate('String91'),
                                    labelStyle: const TextStyle(
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
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 10, 0, 10),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('String26'),
                                      style: TextStyle(
                                          color: ColorTheme.of(context)!
                                              .secondaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.075,
                                  right:
                                      MediaQuery.of(context).size.width * 0.075,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  autovalidateMode: AutovalidateMode.always,
                                  focusNode: focusNodeAddress,
                                  key: walletWindowState!.addressFormKey,
                                  controller:
                                      walletWindowState!.textControllerAddress,
                                  validator: (String? val) {
                                    if (val != '') {
                                      if (val == address) {
                                        return AppLocalizations.of(context)!
                                            .translate('String109');
                                      }
                                      try {
                                        NyzoStringEncoder.decode(val!);
                                        if (NyzoStringEncoder.decode(val)
                                                .getType()
                                                .getPrefix() ==
                                            'pre_') {
                                          final NyzoStringPrefilledData pre =
                                              NyzoStringPrefilledData
                                                  .fromByteBuffer(
                                                      NyzoStringEncoder.decode(
                                                              val)
                                                          .getBytes()
                                                          .buffer);
                                          //setState(() {
                                          walletWindowState!
                                                  .textControllerAddress.text =
                                              NyzoStringEncoder.encode(
                                                  NyzoStringPublicIdentifier(pre
                                                      .getReceiverIdentifier()!));

                                          walletWindowState!
                                                  .textControllerData.text =
                                              utf8.decode(pre.getSenderData()!);
                                        }
                                      } catch (e) {
                                        return InvalidNyzoString().errMsg();
                                      }
                                    } else {
                                      return AppLocalizations.of(context)!
                                          .translate('String110');
                                    }
                                  },
                                  style: TextStyle(
                                      color: ColorTheme.of(context)!
                                          .secondaryColor),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        ColorTheme.of(context)!.depthColor,
                                    contentPadding: const EdgeInsets.all(10),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Image.asset(
                                            'images/qr.png',
                                            color: ColorTheme.of(context)!
                                                .secondaryColor,
                                          ),
                                          onPressed: () {
                                            FocusScope.of(context).unfocus();
                                            final WalletWindowState?
                                                walletWindowState = context
                                                    .findAncestorStateOfType();

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      QrCameraWindow(
                                                          walletWindowState)),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          color: ColorTheme.of(context)!
                                              .secondaryColor,
                                          icon: const Icon(Icons.contacts),
                                          onPressed: () {
                                            getContacts().then(
                                                (List<Contact> _contactList) {
                                              setState(() {
                                                contactsList = _contactList;
                                              });
                                              showPickerDialog(
                                                  context, contactsList!);
                                              FocusScope.of(context).unfocus();
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText: AppLocalizations.of(context)!
                                        .translate('String92'),
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF555555),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Colors.red)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Color(0x55666666))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        borderSide: const BorderSide(
                                            color: Color(0x55666666))),
                                  ),
                                ),
                              ),
                              Container(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Send a token ?',
                                    style: TextStyle(
                                        color: ColorTheme.of(context)!
                                            .secondaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  Switch(
                                    value: isTokenToSendSwitched,
                                    onChanged: (value) async {
                                      myTokensList.clear();
                                      myTokensList.add(Token(
                                          name: '', amount: 0, comment: ''));
                                      myTokensList.addAll(
                                          await getTokensBalance(address));
                                      setState(() {
                                        isTokenToSendSwitched = value;
                                        walletWindowState!
                                            .textControllerTokenComments
                                            .clear();
                                        walletWindowState!
                                            .textControllerTokenQuantity
                                            .clear();
                                      });
                                    },
                                    inactiveTrackColor: ColorTheme.of(context)!
                                        .transparentColor,
                                    activeColor:
                                        ColorTheme.of(context)!.secondaryColor,
                                  ),
                                ],
                              )),
                              isTokenToSendSwitched == false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 0, 10),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('String27'),
                                            style: TextStyle(
                                                color: ColorTheme.of(context)!
                                                    .secondaryColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20),
                                          ),
                                        )
                                      ],
                                    )
                                  : const SizedBox(),
                              isTokenToSendSwitched == false
                                  ? Container(
                                      margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.075,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.075,
                                      ),
                                      child: TextFormField(
                                        focusNode: focusNodeData,
                                        key: walletWindowState!.dataFormKey,
                                        controller: walletWindowState!
                                            .textControllerData,
                                        maxLength: 32,
                                        style: TextStyle(
                                            color: ColorTheme.of(context)!
                                                .secondaryColor),
                                        decoration: InputDecoration(
                                          counterStyle: TextStyle(
                                              color: ColorTheme.of(context)!
                                                  .secondaryColor),
                                          filled: true,
                                          fillColor: ColorTheme.of(context)!
                                              .depthColor,
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .translate('String93'),
                                          labelStyle: const TextStyle(
                                              color: Color(0xFF555555),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Color(0x55666666))),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Color(0x55666666))),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              borderSide: const BorderSide(
                                                  color: Colors.red)),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              isTokenToSendSwitched == true
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 10, 0, 10),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .translate('String104'),
                                                style: TextStyle(
                                                    color:
                                                        ColorTheme.of(context)!
                                                            .secondaryColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.09,
                                          ),
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              canvasColor:
                                                  ColorTheme.of(context)!
                                                      .baseColor,
                                            ),
                                            child: DropdownButtonFormField(
                                              value: _selectedTokenName,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.all(0.0),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: ColorTheme.of(
                                                                context)!
                                                            .secondaryColor!),
                                                  ),
                                                  isDense: true),
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w100,
                                                color: ColorTheme.of(context)!
                                                    .secondaryColor,
                                              ),
                                              isExpanded: true,
                                              items: myTokensList
                                                  .map((Token token) {
                                                return DropdownMenuItem<String>(
                                                    value: token.name,
                                                    child: Container(
                                                        child: token.name == ""
                                                            ? Text(
                                                                'Select a token',
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFF555555),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15),
                                                              )
                                                            : Text(
                                                                token.name! +
                                                                    " (" +
                                                                    token
                                                                        .amount!
                                                                        .toString() +
                                                                    " " +
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .translate(
                                                                            'String107') +
                                                                    ")",
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFF555555),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )));
                                              }).toList(),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _selectedTokenName = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                          ),
                                          child: TextFormField(
                                            keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                signed: false, decimal: true),
                                            focusNode: focusNodeTokenQuantity,
                                            key: walletWindowState!
                                                .tokenQuantityFormKey,
                                            controller: walletWindowState!
                                                .textControllerTokenQuantity,
                                            maxLength: 19,
                                            style: TextStyle(
                                                color: ColorTheme.of(context)!
                                                    .secondaryColor),
                                            decoration: InputDecoration(
                                              counterStyle: TextStyle(
                                                  color: ColorTheme.of(context)!
                                                      .secondaryColor),
                                              filled: true,
                                              fillColor: ColorTheme.of(context)!
                                                  .depthColor,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .translate('String106'),
                                              labelStyle: const TextStyle(
                                                  color: Color(0xFF555555),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Color(0x55666666))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Color(0x55666666))),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                            ),
                                            validator: (String? val) => walletWindowState!
                                                        .textControllerTokenQuantity
                                                        .text ==
                                                    ''
                                                ? AppLocalizations.of(context)!
                                                    .translate('String67')
                                                : double.tryParse(walletWindowState!
                                                            .textControllerTokenQuantity
                                                            .text) ==
                                                        null
                                                    ? AppLocalizations.of(context)!
                                                        .translate('String89')
                                                    : double.tryParse(walletWindowState!.textControllerTokenQuantity.text)!
                                                                .toDouble() >=
                                                            _getTokenQtySelected()
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .translate('String108')
                                                        : null,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.075,
                                          ),
                                          child: TextFormField(
                                            focusNode: focusNodeTokenComments,
                                            key: walletWindowState!
                                                .tokenCommentsFormKey,
                                            controller: walletWindowState!
                                                .textControllerTokenComments,
                                            maxLength: 32,
                                            style: TextStyle(
                                                color: ColorTheme.of(context)!
                                                    .secondaryColor),
                                            decoration: InputDecoration(
                                              counterStyle: TextStyle(
                                                  color: ColorTheme.of(context)!
                                                      .secondaryColor),
                                              filled: true,
                                              fillColor: ColorTheme.of(context)!
                                                  .depthColor,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              labelText:
                                                  AppLocalizations.of(context)!
                                                      .translate('String105'),
                                              labelStyle: const TextStyle(
                                                  color: Color(0xFF555555),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Color(0x55666666))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Color(0x55666666))),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  borderSide: const BorderSide(
                                                      color: Colors.red)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.red)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: ColorTheme.of(context)!
                                                  .secondaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0))),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .translate('String22'),
                                              style: TextStyle(
                                                  color: ColorTheme.of(context)!
                                                      .baseColor)),
                                          onPressed: () {
                                            //var dataForm = dataFormKey.currentState;
                                            final FormFieldState? addressForm =
                                                walletWindowState!
                                                    .addressFormKey
                                                    .currentState;
                                            final FormFieldState? amountForm =
                                                walletWindowState!
                                                    .amountFormKey.currentState;
                                            final FormFieldState?
                                                tokenQuantity =
                                                walletWindowState!
                                                    .tokenQuantityFormKey
                                                    .currentState;
                                            if (addressForm!.validate() &&
                                                amountForm!.validate() &&
                                                (isTokenToSendSwitched ==
                                                        false ||
                                                    isTokenToSendSwitched &&
                                                        tokenQuantity!
                                                            .validate())) {
                                              final String address =
                                                  walletWindowState!
                                                      .textControllerAddress
                                                      .text;
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              int _amount = (double.parse(
                                                          walletWindowState!
                                                              .textControllerAmount
                                                              .text) *
                                                      1000000)
                                                  .toInt();
                                              String _data = '';
                                              if (isTokenToSendSwitched ==
                                                  true) {
                                                _data = Token(
                                                        name:
                                                            _selectedTokenName,
                                                        amount: double.tryParse(
                                                            walletWindowState!
                                                                .textControllerTokenQuantity
                                                                .text),
                                                        comment: walletWindowState!
                                                            .textControllerTokenComments
                                                            .text)
                                                    .getSenderData();
                                              } else {
                                                _data = walletWindowState!
                                                    .textControllerData.text;
                                              }

                                              send(
                                                      password,
                                                      address,
                                                      _amount,
                                                      walletWindowState!
                                                          .balance,
                                                      _data)
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
                                                                context)!
                                                            .translate(
                                                                'String28'),
                                                        style: TextStyle(
                                                            color: ColorTheme.of(
                                                                    context)!
                                                                .secondaryColor),
                                                      ),
                                                      content: Text(result),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .translate(
                                                                      'String29')),
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
                                              walletWindowState!
                                                  .textControllerAddress
                                                  .clear();
                                              walletWindowState!
                                                  .textControllerAmount
                                                  .clear();
                                              walletWindowState!
                                                  .textControllerData
                                                  .clear();
                                              walletWindowState!
                                                  .textControllerTokenComments
                                                  .clear();
                                              walletWindowState!
                                                  .textControllerTokenQuantity
                                                  .clear();
                                              _selectedTokenName = '';
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
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                        child: Container(
                          width: 200.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200.withOpacity(0)),
                          child: Center(
                            child: SpinKitChasingDots(
                              color: ColorTheme.of(context)!.secondaryColor,
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
          else
            Container(),
        ],
      ),
    );
  }

  double _getTokenQtySelected() {
    double? value = 0;
    myTokensList.forEach((token) {
      if (token.name == _selectedTokenName) {
        value = token.amount;
      }
    });
    return value!;
  }
}
