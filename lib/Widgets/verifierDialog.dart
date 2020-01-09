import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/NyzoStringPrefilledData.dart';
import 'package:nyzo_wallet/Data/NyzoStringPublicIdentifier.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import 'package:nyzo_wallet/Data/watchedAddress.dart';
import "package:hex/hex.dart";

class AddVerifierDialog {
  static final TextEditingController nameController = TextEditingController();

  static final nameFormKey = GlobalKey<FormFieldState>();
  information(BuildContext context2, String title, bool isVerifier,
      {VoidCallback onClose}) {
    return showDialog(
        context: context2,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        isVerifier
                            ? AppLocalizations.of(context).translate("String96")
                            : AppLocalizations.of(context)
                                .translate("String98"),
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Container(
                    child: TextFormField(
                  validator: isVerifier
                      ? (String val) => val == ''
                          ? AppLocalizations.of(context).translate("String67")
                          : null
                      : (String val) {
                          try {
                            NyzoStringEncoder.decode(val);
                            if (NyzoStringEncoder.decode(val)
                                    .getType()
                                    .getPrefix() ==
                                'pre_') {
                              NyzoStringPrefilledData pre =
                                  NyzoStringPrefilledData.fromByteBuffer(
                                      NyzoStringEncoder.decode(val)
                                          .getBytes()
                                          .buffer);
                              //setState(() {
                              nameController.text = NyzoStringEncoder.encode(
                                  NyzoStringPublicIdentifier(
                                      pre.getReceiverIdentifier()));
                              print(NyzoStringEncoder.encode(
                                  NyzoStringPublicIdentifier(
                                      pre.getReceiverIdentifier())));

                              //});
                            }
                          } catch (e) {
                            if (e.runtimeType == InvalisNyzoString) {
                              return e.errMsg();
                            }
                          }
                          return null;
                        },
                  key: nameFormKey,
                  controller: nameController,
                  maxLength: 67,
                  decoration: InputDecoration(
                    hintText: "ID",
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
                    labelText: "",
                    labelStyle: TextStyle(
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                )),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String34")),
                onPressed: () {
                  nameController.text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String71")),
                onPressed: () async {
                  nameFormKey.currentState.validate();
                  isVerifier
                      ? addVerifier(Verifier.fromId(
                          nameController.text,
                        )).then((s) {
                          onClose();
                          Navigator.pop(context);
                          nameController.text = '';
                        })
                      : addWatchAddress(WatchedAddress.fromAddress(
                          HEX.encode(
                              NyzoStringEncoder.decode(nameController.text)
                                  .getBytes()),
                        )).then((s) {
                          onClose();
                          Navigator.pop(context);
                          nameController.text = '';
                        });
                },
              ),
            ],
          );
        });
  }
}
