import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Contact.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';

class AddContactDialog {

  static final TextEditingController addressController =
      new TextEditingController();
  static final TextEditingController nameController =
      new TextEditingController();
  static final TextEditingController dataController =
      new TextEditingController();
  static final addressFormKey = new GlobalKey<FormFieldState>();
  static final dataFormKey = new GlobalKey<FormFieldState>();
  static final nameFormKey = new GlobalKey<FormFieldState>();
  information(BuildContext context2, String title, List<Contact> contactList,
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
            content: Container(
                child: TextFormField(
              validator: (String val) =>
                  val == '' ? AppLocalizations.of(context).translate("String67") : null,
              key: nameFormKey,
              controller: nameController,
              maxLength: 24,
              decoration: InputDecoration(
                hasFloatingPlaceholder: false,
                labelText: AppLocalizations.of(context).translate("String68"),
                labelStyle: TextStyle(
                  
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide:
                                      BorderSide(color: Color(0x55666666))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide:
                                      BorderSide(color: Color(0x55666666))),
              ),
            )),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String34")),
                onPressed: () {
                  nameController.text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String15")),
                onPressed: () {
                  if (nameFormKey.currentState.validate()) {
                    Navigator.pop(context);
                    address(context2, AppLocalizations.of(context).translate("String69"), contactList,
                        onClose: onClose);
                  }
                },
              ),
            ],
          );
        });
  }

  address(BuildContext context2, String title, List<Contact> contactList,
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
            content: TextFormField(
              key: addressFormKey,
              controller: addressController,
              maxLines: 3,
              maxLength: 67,
              validator: (String val){
                              if (val.length != 56) {
                                return AppLocalizations.of(context)
                                    .translate("String70");
                              }
                              try {
                                NyzoStringEncoder.decode(val);
                              } catch (e) {
                                return e.errMsg();
                              }
                              return null;
                            },
              
              decoration: InputDecoration(
                hasFloatingPlaceholder: false,
                labelText: AppLocalizations.of(context).translate("String9"),
                labelStyle: TextStyle(
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
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
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String34")),
                onPressed: () {
                  nameController.text = '';
                  addressController.text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String15")),
                onPressed: () {
                  var addressForm = addressFormKey.currentState;
                  if (addressForm.validate()) {
                    Navigator.pop(context);
                    data(context2, AppLocalizations.of(context).translate("String69"), contactList,
                        onClose: onClose);
                  }
                },
              ),
            ],
          );
        });
  }

  data(BuildContext context2, String title, List<Contact> contactList,
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
            content: TextFormField(
              key: dataFormKey,
              controller: dataController,
              maxLength: 32,
              
              
              decoration: InputDecoration(
                hasFloatingPlaceholder: false,
                labelText: 	AppLocalizations.of(context).translate("String11"),
                labelStyle: TextStyle(
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(color: Colors.red)),
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
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String34")),
                onPressed: () {
                  nameController.text = '';
                  addressController.text = '';
                  dataController.text = '';
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate("String71")),
                onPressed: () async {
                  addContact(
                          contactList,
                          new Contact(addressController.text,
                              nameController.text, dataController.text))
                      .then((s) {
                    onClose();
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
