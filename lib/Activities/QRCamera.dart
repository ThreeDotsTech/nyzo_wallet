

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:nyzo_wallet/Activities/WalletWindow.dart';

class QrCameraWindow extends StatefulWidget {
  QrCameraWindow(this.walletWindowState);
  final WalletWindowState walletWindowState;

  @override
  _QrCameraWindowState createState() => _QrCameraWindowState();
}

class _QrCameraWindowState extends State<QrCameraWindow> {
  bool hasScanned = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        /*child: QrCamera(qrCodeCallback: (String scanned) {
          widget.walletWindowState.textControllerAddress.text = scanned;

          if (!hasScanned) {
            Navigator.pop(context);
            hasScanned = true;
          }
        })*/
      ),
    );
  }
}
