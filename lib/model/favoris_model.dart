import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class FavorisModel {
  String? id_users; //
  String? id_evenements; //
  EvenementModel? evenements;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;

  FavorisModel(
      {
      this.id_users,
      this.id_evenements,
      this.created_at,
      this.updated_at,
      this.evenements});

  factory FavorisModel.fromJson(Map<String, dynamic> json) {
    return FavorisModel(
      id_users: json["id_users"].toString(),
      id_evenements: json["id_evenements"].toString(),
      evenements: (json["evenements"] == null || json["evenements"] == '')
          ? new EvenementModel(banner_path: '')
          : EvenementModel.fromJson(json["evenements"]),
      created_at: (json["created_at"] == null || json["created_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["updated_at"]),
    );
  }
  String toRYString() =>
      '{"id_evenements": "${this.id_evenements}","id_users": "${this.id_users}","created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}
