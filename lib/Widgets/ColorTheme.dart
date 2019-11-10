import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Data/Verifier.dart';
import 'package:nyzo_wallet/Data/watchedAddress.dart';

class ColorTheme extends InheritedWidget {
  ColorTheme(
      {this.lightTheme,
      this.child,
      this.update,
      this.baseColor,
      this.secondaryColor,
      this.extraColor,
      this.transparentColor,
      this.highLigthColor,
      this.verifiersList,
      this.updateVerifiers,
      this.addressesToWatch,
      this.balanceList,
      this.getBalanceList,
      this.updateAddressesToWatch})
      : super(child: child);
  final Widget child;
  final bool lightTheme;
  final Function update;
  final Color baseColor;
  final Color secondaryColor;
  final Color extraColor;
  final Color transparentColor;
  final Color highLigthColor;
  final List<Verifier> verifiersList;
  final Function updateVerifiers;
  final List<WatchedAddress> addressesToWatch;
  final List<List<String>> balanceList;
  final Function getBalanceList;
  final Function updateAddressesToWatch;

  @override
  bool updateShouldNotify(ColorTheme oldWidget) {
    print(((lightTheme != oldWidget.lightTheme) ||
            (verifiersList != oldWidget.verifiersList))
        .toString());
    return ((lightTheme != oldWidget.lightTheme) ||
        (verifiersList != oldWidget.verifiersList) ||
        (addressesToWatch != oldWidget.addressesToWatch));
  }

  static ColorTheme of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ColorTheme);
  }
}
