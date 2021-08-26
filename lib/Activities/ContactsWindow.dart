// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:expandable/expandable.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/WalletWindow.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';
import 'package:nyzo_wallet/Widgets/Dialog.dart';

class ContactsWindow extends StatefulWidget {
  final List<Contact> _contacts;
  const ContactsWindow(this._contacts);
  @override
  ContactsWindowState createState() => ContactsWindowState(_contacts);
}

class ContactsWindowState extends State<ContactsWindow> {
  ContactsWindowState(this.contactsList);
  List<Contact>? contactsList;
  final SlidableController slidableController = SlidableController();
  final ExpandableController expandableController = ExpandableController();
  AddContactDialog floatingdialog = AddContactDialog();
  WalletWindowState? walletWindowState;

  @override
  void initState() {
    walletWindowState = context.findAncestorStateOfType<WalletWindowState>();
    getContacts().then((List<Contact> contactList) {
      setState(() {
        contactsList = contactList;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(),
        ),
        Center(
          child: Text(
            AppLocalizations.of(context)!.translate('String8'),
            style: TextStyle(
                color: ColorTheme.of(context)!.secondaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                fontSize: 35),
          ),
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Container(
              child: Stack(
                children: <Widget>[
                  contactsList != null
                      ? contactsList!.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.all(0.0),
                              itemCount: contactsList?.length,
                              itemBuilder: (context, i) => Slidable(
                                    controller: slidableController,
                                    actionPane:
                                        const SlidableDrawerActionPane(),
                                    child: ExpandablePanel(
                                      header: ListTile(
                                        leading: Icon(
                                          Icons.person,
                                          color: ColorTheme.of(context)!
                                              .secondaryColor,
                                        ),
                                        title: Text(contactsList![i].name,
                                            style: TextStyle(
                                              color: ColorTheme.of(context)!
                                                  .secondaryColor,
                                              fontSize: 20.0,
                                            )),
                                      ),
                                      expanded: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                75, 0, 0, 0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  125,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .translate('String9'),
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF555555),
                                                        fontSize: 15),
                                                  ),
                                                  RichText(
                                                    overflow: TextOverflow.fade,
                                                    maxLines: 2,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    text: TextSpan(
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: contactsList![
                                                                              i]
                                                                          .address));
                                                              final snackBar = SnackBar(
                                                                  content: Text(AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'String10')));
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      snackBar);
                                                            },
                                                      style: TextStyle(
                                                          color: ColorTheme.of(
                                                                  context)!
                                                              .secondaryColor),
                                                      text: contactsList![i]
                                                          .address,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 15, 0, 0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .translate(
                                                              'String11'),
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF555555),
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorTheme.of(
                                                              context)!
                                                          .depthColor,
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .red)),
                                                      errorBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Color(
                                                                      0x55666666))),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Color(
                                                                      0x55666666))),
                                                    ),
                                                    style: TextStyle(
                                                        color: ColorTheme.of(
                                                                context)!
                                                            .secondaryColor),
                                                    initialValue:
                                                        contactsList![i].notes,
                                                    textAlign: TextAlign.center,
                                                    onFieldSubmitted:
                                                        (String newData) {
                                                      contactsList![i].notes =
                                                          newData;
                                                      saveContacts(
                                                          contactsList!);
                                                      getContacts().then(
                                                          (List<Contact>
                                                              _contactList) {
                                                        setState(() {
                                                          contactsList =
                                                              _contactList;
                                                        });
                                                      });
                                                    },
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: ColorTheme.of(
                                                                    context)!
                                                                .secondaryColor,
                                                          ),
                                                          onPressed: () {
                                                            contactsList!
                                                                .removeAt(i);
                                                            setState(() {
                                                              saveContacts(
                                                                  contactsList!);
                                                            });
                                                          },
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Container(),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.send,
                                                            color: ColorTheme.of(
                                                                    context)!
                                                                .secondaryColor,
                                                          ),
                                                          onPressed: () {
                                                            walletWindowState!
                                                                    .textControllerAddress
                                                                    .text =
                                                                contactsList![i]
                                                                    .address;
                                                            walletWindowState!
                                                                    .textControllerData
                                                                    .text =
                                                                contactsList![i]
                                                                    .notes;
                                                            walletWindowState!
                                                                .setState(() {
                                                              walletWindowState!
                                                                  .pageIndex = 2;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      collapsed: const SizedBox(),
                                    ),
                                    actions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Send',
                                        color:
                                            ColorTheme.of(context)!.baseColor,
                                        icon: Icons.send,
                                        onTap: () {
                                          walletWindowState!
                                              .textControllerAddress
                                              .text = contactsList![i].address;
                                          walletWindowState!.textControllerData
                                              .text = contactsList![i].notes;
                                          walletWindowState!.setState(() {
                                            walletWindowState!.pageIndex = 2;
                                          });
                                        },
                                      )
                                    ],
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color:
                                            ColorTheme.of(context)!.baseColor,
                                        icon: Icons.delete,
                                        onTap: () {
                                          contactsList!.removeAt(i);
                                          setState(() {
                                            saveContacts(contactsList!);
                                          });
                                        },
                                      ),
                                    ],
                                  ))
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Image.asset(
                                    'images/noContacts.png',
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
                                    height:
                                        walletWindowState!.screenHeight! / 6,
                                    //width: walletWindowState.screenHeight / 5 * 0.9,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('String12'),
                                        style: const TextStyle(
                                            color: Color(0xFF555555),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('String13'),
                                        style: const TextStyle(
                                            color: Color(0xFF666666),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(),
                                  ),
                                ],
                              ),
                            )
                      : ListView.builder(
                          padding: const EdgeInsets.all(0.0),
                          itemCount: 8,
                          itemBuilder: (context, i) => Card(
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
                  Positioned(
                    bottom: MediaQuery.of(context).size.height / 75,
                    right: MediaQuery.of(context).size.height / 100,
                    child: FloatingActionButton(
                      elevation: 5,
                      backgroundColor: ColorTheme.of(context)!.baseColor,
                      foregroundColor: ColorTheme.of(context)!.secondaryColor,
                      onPressed: () {
                        floatingdialog.information(
                            context,
                            AppLocalizations.of(context)!.translate('String69'),
                            contactsList!, onClose: () {
                          getContacts().then((List<Contact> _contactList) {
                            setState(() {
                              contactsList = _contactList;
                            });
                          });
                        });
                        //contactsList!.add(addcontact);
                      },
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: const Icon(Icons.add)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
