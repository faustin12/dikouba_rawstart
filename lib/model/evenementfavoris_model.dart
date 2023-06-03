import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class EvenementFavorisModel {
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  String? id_users;
  String? id_evenements;
  EvenementModel? evenements;

  EvenementFavorisModel(
      {this.created_at,
      this.updated_at,
      this.id_users,
      this.id_evenements,
      this.evenements});

  factory EvenementFavorisModel.fromJson(Map<String, dynamic> json) {
    return EvenementFavorisModel(
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      evenements: (json["evenements"] == null || json["evenements"] == '') ? new EvenementModel(banner_path: '') : EvenementModel.fromJson(json["evenements"]),
      id_users: json["id_categories"].toString(),
      id_evenements: json["id_evenements"].toString(),
    );
  }

  String toRYString() => '{"id_users": "${this.id_users}","id_evenements": "${this.id_evenements}","evenements": ${this.evenements?.toRYString()},"created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}