// @dart=2.9

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class MyTokensListWindow extends StatefulWidget {
  final List<NyzoToken> listNyzoToken;

  MyTokensListWindow(this.listNyzoToken) : super();

  _MyTokensListWindowStateState createState() =>
      _MyTokensListWindowStateState();
}

class _MyTokensListWindowStateState extends State<MyTokensListWindow> {
  List<NyzoToken> _myNyzoTokenList = new List<NyzoToken>();
  List<NyzoToken> _myNyzoTokenListForDisplay = new List<NyzoToken>();

  @override
  void initState() {
    //

    setState(() {
      _myNyzoTokenList.addAll(widget.listNyzoToken);
      _myNyzoTokenList.removeWhere((element) => element.tokenName == "");
      _myNyzoTokenListForDisplay = _myNyzoTokenList;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // A row for the address text and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 40,
                ),
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context).curTheme.text10,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ],
                ),
                //Empty SizedBox
                SizedBox(
                  width: 60,
                  height: 40,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate('String72'),
                    style: TextStyle(
                        color: ColorTheme.of(context).secondaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        fontSize: 35),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Stack(children: <Widget>[
                  Container(
                      height: 500,
                      child: SafeArea(
                        minimum: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.035,
                          top: 60,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: AppLocalization.of(context)
                                        .searchField),
                                onChanged: (text) {
                                  text = text.toLowerCase();
                                  setState(() {
                                    _myNyzoTokenListForDisplay =
                                        _myNyzoTokenList.where((token) {
                                      var tokenId =
                                          token.tokenName.toLowerCase();
                                      return tokenId.contains(text);
                                    }).toList();
                                  });
                                },
                              ),
                            ),
                            // list
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  //  list
                                  ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding:
                                        EdgeInsets.only(top: 15.0, bottom: 15),
                                    itemCount:
                                        _myNyzoTokenListForDisplay == null
                                            ? 0
                                            : _myNyzoTokenListForDisplay.length,
                                    itemBuilder: (context, index) {
                                      // Build
                                      return buildSingleToken(context,
                                          _myNyzoTokenListForDisplay[index]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ]),
              ),
            ),
          ],
        ));
  }

  Widget buildSingleToken(BuildContext context, NyzoToken bisToken) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: Column(children: <Widget>[
        Divider(
          height: 2,
        ),
        // Main Container
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          margin: new EdgeInsetsDirectional.only(start: 12.0, end: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 40,
                  margin: EdgeInsetsDirectional.only(start: 2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                  NumberFormat.compact(
                                              locale: Localizations.localeOf(
                                                      context)
                                                  .languageCode)
                                          .format(bisToken.tokensQuantity) +
                                      " " +
                                      bisToken.tokenName,
                                  style: AppStyles.textStyleSettingItemHeader(
                                      context)),
                              SizedBox(
                                width: 5,
                              ),
                              TokenRef().getIcon(bisToken.tokenName),
                            ],
                          ),
                          bisToken.tokensQuantity > 0
                              ? SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                    child: Container(
                                      height: 36,
                                      width: 36,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Sheets.showAppHeightNineSheet(
                                              context: context,
                                              widget: SendSheet(
                                                sendATokenActive: true,
                                                operation:
                                                    AddressTxsResponseResult
                                                        .TOKEN_TRANSFER,
                                                selectedTokenName:
                                                    bisToken.tokenName,
                                                localCurrency:
                                                    StateContainer.of(context)
                                                        .curCurrency,
                                              ));
                                        },
                                        child: Icon(
                                            FontAwesome5.arrow_circle_up,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .primary),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
