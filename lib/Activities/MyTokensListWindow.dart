// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'package:nyzo_wallet/Data/Token.dart';
import 'package:nyzo_wallet/Widgets/ColorTheme.dart';

class MyTokensListWindow extends StatefulWidget {
  const MyTokensListWindow(this.tokensList, this.nftsList) : super();

  final List<Token> tokensList;
  final List<Token> nftsList;

  @override
  _MyTokensListWindowStateState createState() =>
      _MyTokensListWindowStateState();
}

class _MyTokensListWindowStateState extends State<MyTokensListWindow> {
  final List<Token> _myTokenList = List<Token>.empty(growable: true);
  List<Token> _myTokenListForDisplay = List<Token>.empty(growable: true);

  @override
  void initState() {
    //

    setState(() {
      _myTokenList.addAll(widget.tokensList);
      _myTokenList.addAll(widget.nftsList);
      _myTokenList.sort(
          (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
      _myTokenList.removeWhere((Token element) => element.name == '');
      _myTokenListForDisplay = _myTokenList;
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
                const SizedBox(
                  width: 60,
                  height: 40,
                ),
                Column(
                  children: <Widget>[
                    // Sheet handle
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: MediaQuery.of(context).size.width * 0.15,
                      decoration: BoxDecoration(
                        color: ColorTheme.of(context)!.secondaryColor,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ],
                ),
                //Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 40,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate('String102'),
                    style: TextStyle(
                        color: ColorTheme.of(context)!.secondaryColor,
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
                                    hintText: AppLocalizations.of(context)!
                                        .translate('String103'),
                                    hintStyle: TextStyle(
                                        color: ColorTheme.of(context)!
                                            .secondaryColor,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                        fontSize: 16),
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF555555))),
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFF555555)))),
                                onChanged: (String text) {
                                  text = text.toLowerCase();
                                  setState(() {
                                    _myTokenListForDisplay =
                                        _myTokenList.where((Token token) {
                                      final String tokenId =
                                          token.name!.toLowerCase() +
                                              ' ' +
                                              token.uid!.toLowerCase();
                                      return tokenId.contains(text);
                                    }).toList();
                                  });
                                },
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    fontSize: 16),
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
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15),
                                    itemCount: _myTokenListForDisplay == null
                                        ? 0
                                        : _myTokenListForDisplay.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      // Build
                                      return buildSingleToken(context,
                                          _myTokenListForDisplay[index]);
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

  Widget buildSingleToken(BuildContext context, Token token) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      child: Column(children: <Widget>[
        const Divider(
          height: 2,
        ),
        // Main Container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          margin: const EdgeInsetsDirectional.only(start: 12.0, end: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsetsDirectional.only(start: 2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                token.isNFT
                                    ? token.name! + ' : ' + token.uid!
                                    : token.name! +
                                        ' : ' +
                                        token.amount.toString(),
                                style: TextStyle(
                                    color:
                                        ColorTheme.of(context)!.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    fontSize: 16),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
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
