import 'package:dikouba_rawstart/model/firebasedate_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';

class ParticipantModel {
  String? id_tickets;
  String? id_packages;
  String? id_evenements;
  String? id_users;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  UserModel? users;

  ParticipantModel({this.id_tickets, this.id_packages, this.id_evenements,
      this.id_users, this.created_at, this.updated_at, this.users});

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id_tickets: json["id_tickets"].toString(),
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      id_packages: json["id_packages"].toString(),
      id_evenements: json["id_evenements"].toString(),
      id_users: json["id_users"].toString(),
      users: (json["users"] == null || json["users"] == '') ? new UserModel(id_users: '') : UserModel.fromJson(json["users"]),
    );
  }
  // String toRYString() => '{"title": "${this.title}","description": "${this.description}","id_categories": "${this.id_categories}","users": ${this.users.toRYString()},"created_at": ${this.created_at.toRYString()},"updated_at": ${this.updated_at.toRYString()}}';

}
