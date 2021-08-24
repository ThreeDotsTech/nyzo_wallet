// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';

class AddContactDialog {
  static final TextEditingController addressController =
      TextEditingController();
  static final TextEditingController nameController = TextEditingController();
  static final TextEditingController dataController = TextEditingController();
  static final addressFormKey = GlobalKey<FormFieldState>();
  static final dataFormKey = GlobalKey<FormFieldState>();
  static final nameFormKey = GlobalKey<FormFieldState>();
  information(BuildContext context2, String title, List<Contact> contactList,
      {VoidCallback? onClose}) {
    return showDialog(
        context: context2,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
            content: Container(
                child: TextFormField(
              validator: (String? val) => val == ''
                  ? AppLocalizations.of(context)!.translate('String67')
                  : null,
              key: nameFormKey,
              controller: nameController,
              maxLength: 24,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: AppLocalizations.of(context)!.translate('String68'),
                labelStyle: const TextStyle(
                    color: const Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide:
                        const BorderSide(color: const Color(0x55666666))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0x55666666))),
              ),
            )),
            actions: <Widget>[
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String34')),
                onPressed: () {
                  nameController.text = '';
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String15')),
                onPressed: () {
                  if (nameFormKey.currentState!.validate()) {
                    Navigator.pop(context);
                    address(
                        context2,
                        AppLocalizations.of(context)!.translate('String69'),
                        contactList,
                        onClose: onClose!);
                  }
                },
              ),
            ],
          );
        });
  }

  address(BuildContext context2, String title, List<Contact> contactList,
      {VoidCallback? onClose}) {
    return showDialog(
        context: context2,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              key: addressFormKey,
              controller: addressController,
              maxLines: 3,
              validator: (String? val) {
                if (val!.length != 56) {}
                try {
                  NyzoStringEncoder.decode(val);
                } catch (e) {
                  return AppLocalizations.of(context)!.translate('String70');
                }

                try {
                  NyzoStringEncoder.decode(val);
                  if (NyzoStringEncoder.decode(val).getType().getPrefix() ==
                      'pre_') {
                    final NyzoStringPrefilledData pre =
                        NyzoStringPrefilledData.fromByteBuffer(
                            NyzoStringEncoder.decode(val).getBytes().buffer);
                    //setState(() {
                    addressController.text = NyzoStringEncoder.encode(
                        NyzoStringPublicIdentifier(
                            pre.getReceiverIdentifier()!));
                    print(NyzoStringEncoder.encode(NyzoStringPublicIdentifier(
                        pre.getReceiverIdentifier()!)));
                    dataController.text = utf8.decode(pre.getSenderData()!);
                    print(utf8.decode(pre.getSenderData()!));
                    //});
                  }
                } catch (e) {
                  if (e.runtimeType == InvalisNyzoString) {
                    return e.toString();
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: AppLocalizations.of(context)!.translate('String9'),
                labelStyle: const TextStyle(
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0x55666666))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0x55666666))),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String34')),
                onPressed: () {
                  nameController.text = '';
                  addressController.text = '';
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String15')),
                onPressed: () {
                  final addressForm = addressFormKey.currentState;
                  if (addressForm!.validate()) {
                    if (dataController.text != '') {
                      addContact(
                              contactList,
                              Contact(addressController.text,
                                  nameController.text, dataController.text))
                          .then((s) {
                        onClose!();
                        Navigator.pop(context);
                        nameController.text = '';
                        addressController.text = '';
                        dataController.text = '';
                      });
                    }
                    Navigator.pop(context);
                    data(
                        context2,
                        AppLocalizations.of(context)!.translate('String69'),
                        contactList,
                        onClose: onClose!);
                  }
                },
              ),
            ],
          );
        });
  }

  data(BuildContext context2, String title, List<Contact> contactList,
      {VoidCallback? onClose}) {
    return showDialog(
        context: context2,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
            content: TextFormField(
              key: dataFormKey,
              controller: dataController,
              maxLength: 32,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: AppLocalizations.of(context)!.translate('String11'),
                labelStyle: const TextStyle(
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.red)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0x55666666))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Color(0x55666666))),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String34')),
                onPressed: () {
                  nameController.text = '';
                  addressController.text = '';
                  dataController.text = '';
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child:
                    Text(AppLocalizations.of(context)!.translate('String71')),
                onPressed: () async {
                  addContact(
                          contactList,
                          Contact(addressController.text, nameController.text,
                              dataController.text))
                      .then((s) {
                    onClose!();
                    Navigator.pop(context);
                    nameController.text = '';
                    addressController.text = '';
                    dataController.text = '';
                  });
                },
              ),
            ],
          );
        });
  }
}
