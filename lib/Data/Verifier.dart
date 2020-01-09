import 'package:flutter/material.dart';
import 'package:nyzo_wallet/Data/NyzoStringEncoder.dart';
import 'package:nyzo_wallet/Data/Wallet.dart';
import "package:hex/hex.dart";

class Verifier {
  static const int ACTIVE = 0;
  static const int COMMUNICATION_PROBLEM = 1;
  static const int TRACKING_PROBLEM = 2;
  static const int NOT_PRODUCING = 3;
  String iPAddress = "";
  String lastQueried = "";
  String nickname = "";
  String version = "";
  String id = "";
  String mesh = "";
  String cycleLength = "";
  String transactions = "";
  String retentionEdge = "";
  String trailingEdge = "";
  String frozenEdge = "";
  String openEdge = "";
  String blocksCT = "";
  String blockVote = "";
  String lastRemovalHeight = "";
  String receivingUDP = "";
  String addres = "";
  double balance;
  int status;
  bool inCicle;
  bool isValid = false;
  Widget iconBlack = Image.asset("images/communicationProblem.png");
  Widget iconWhite = Image.asset(
    "images/communicationProblem.png",
    color: Colors.white,
  );

  Verifier._fromId(this.id);

  static Verifier fromId(String id) {
    Verifier verifier;
    if (id.length>56) {
      id = id.split("-").join('');
      verifier = Verifier._fromId(id.substring(0, 4) + "." + id.substring(60));
    } else if (id.length == 56) {
      verifier = Verifier._fromId(HEX.encode(NyzoStringEncoder.decode(id).getBytes()).substring(0, 4) + "."+HEX.encode(NyzoStringEncoder.decode(id).getBytes()).substring(60));
    } else{
      verifier = Verifier._fromId(id);
    }
    return verifier;
  }

 

  Future<Verifier> update() async {
    await getVerifierStatus(this);
    return this;
  }

  Verifier.fromJson(Map<String, dynamic> data) : id = data['id'];

  Map<String, dynamic> toJson() => {'id': id};
}
