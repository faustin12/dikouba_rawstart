import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebasedate_model.dart';
import 'package:dikouba_rawstart/model/transaction_model.dart';

class TicketModel {
  String? id_tickets;
  String? evenn_presence;
  String? payment_channel_name;
  String? id_packages;
  String? payment_paymentid;
  String? id_users;
  String? statut;
  String? payment_message;
  String? payment_status;
  String? qrcode_validate;
  String? id_evenements;
  String? payment_channel;
  String? payment_method;
  EvenementModel? evenements;
  TransactionModel? transaction;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;

  TicketModel(
      {this.id_tickets,
      this.evenn_presence,
      this.payment_channel_name,
      this.id_packages,
      this.payment_paymentid,
      this.id_users,
      this.statut,
      this.payment_message,
      this.payment_status,
      this.qrcode_validate,
      this.id_evenements,
      this.payment_channel,
      this.payment_method,
      this.created_at,
      this.updated_at,
      this.evenements,
      this.transaction});

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id_tickets: json["id_tickets"].toString(),
      evenn_presence: json["evenn_presence"].toString(),
      payment_channel_name: json["payment_channel_name"].toString(),
      id_packages: json["id_packages"].toString(),
      payment_paymentid: json["payment_paymentid"].toString(),
      id_users: json["id_users"].toString(),
      statut: json["statut"].toString(),
      payment_message: json["payment_message"].toString(),
      payment_status: json["payment_status"].toString(),
      qrcode_validate: json["qrcode_validate"].toString(),
      id_evenements: json["id_evenements"].toString(),
      payment_channel: json["payment_channel"].toString(),
      payment_method: json["payment_method"].toString(),
      evenements: (json["evenements"] == null || json["evenements"] == '')
          ? new EvenementModel(banner_path: '')
          : EvenementModel.fromJson(json["evenements"]),
      // transaction: (!json.containsKey("transaction") ||
      //         json["transaction"] == null ||
      //         json["transaction"] == '')
      //     ? new TransactionModel()
      //     : TransactionModel.fromJson(json["transaction"]),
      created_at: (json["created_at"] == null || json["created_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["updated_at"]),
    );
  }
  String toRYString() =>
      '{"id_tickets": "${this.id_tickets}","evenn_presence": "${this.evenn_presence}","payment_channel_name": "${this.payment_channel_name}","created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}
