import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';

class Verifier {
  static const int ACTIVE = 0;
  static const int COMMUNICATION_PROBLEM = 1;
  static const int TRACKING_PROBLEM = 2;
  static const int NOT_PRODUCING = 3;
  String iPAddress="";
  String lastQueried="";
  String nickname="";
  String version="";
  String id="";
  String mesh="";
  String cycleLength="";
  String transactions="";
  String retentionEdge="";
  String trailingEdge="";
  String frozenEdge="";
  String openEdge="";
  String blocksCT="";
  String blockVote="";
  String lastRemovalHeight="";
  String receivingUDP="";
  String addres="";
  double balance;
  int status;
  bool inCicle;
  bool isValid = false;
  Widget iconBlack =  Image.asset("images/communicationProblem.png");
  Widget iconWhite =  Image.asset("images/communicationProblem.png",color: Colors.white,);

  Verifier.fromId(this.id);

  Future<Verifier> update() async {
    await getVerifierStatus(this);
    return this;
  }

  Verifier.fromJson(Map<String, dynamic> data) : id = data['id'];

  Map<String, dynamic> toJson() => {'id': id};
}
