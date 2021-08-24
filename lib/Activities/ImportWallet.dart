// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/ImportWallet2.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class ImportWalletScreen extends StatefulWidget {
  @override
  _ImportWalletScreenState createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  bool _isLoading = false;

  final privKeytextController = TextEditingController();
  final formKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    //prevent the screen from rotating
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _performWalletCreation() {
    setState(() {
      _isLoading = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ImportWalletScreen2(privKeytextController.text)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Center(
                      child: Text(
                          AppLocalizations.of(context)!.translate('String14'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          )))),
              TextFormField(
                key: formKey,
                autocorrect: false,
                autofocus: false,
                obscureText: true,
                maxLength: 56,
                controller: privKeytextController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorTheme.of(context)!.dephtColor,
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
                  contentPadding: const EdgeInsets.all(10),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText:
                      AppLocalizations.of(context)!.translate('String82'),
                  labelStyle: const TextStyle(
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
                validator: (String? val) {
                  if (val!.length != 56) {
                    return AppLocalizations.of(context)!.translate('String70');
                  }
                  try {
                    NyzoStringEncoder.decode(val);
                  } catch (e) {
                    return e.toString();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 50.0,
              ),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Color(0XFFFFFFFF))))
                  : Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black87,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
                        onPressed: () {
                          final form = formKey.currentState;
                          if (form!.validate()) {
                            _performWalletCreation();
                          }
                        },
                        child: Text(
                            AppLocalizations.of(context)!.translate('String15'),
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ));
  }
}
