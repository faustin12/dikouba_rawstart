import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class AnnoncerModel {
  String? id_annoncers;
  String? id_users;
  String? compagny;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  String? picture_path;
  String? cover_picture_path;
  String? checkout_phone_number;

  AnnoncerModel(
    {this.id_annoncers,
      this.id_users,
      this.compagny,
      this.created_at,
      this.updated_at,
      this.picture_path,
      this.cover_picture_path,
      this.checkout_phone_number});

  factory AnnoncerModel.fromJson(Map<String, dynamic> json) {
    return AnnoncerModel(
        id_users: json["id_users"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      compagny: json["compagny"].toString(),
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      picture_path: json["picture_path"].toString(),
      cover_picture_path: json["cover_picture_path"].toString(),
      checkout_phone_number: json["checkout_phone_number"].toString()
    );
  }

  factory AnnoncerModel.fromJsonDb(Map<String, dynamic> json) {
    return AnnoncerModel(
      id_users: json["id_users"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      compagny: json["compagny"].toString(),
      picture_path: json["picture_path"].toString(),
      cover_picture_path: json["cover_picture_path"].toString(),
      checkout_phone_number: json["checkout_phone_number"].toString()
    );
  }
}