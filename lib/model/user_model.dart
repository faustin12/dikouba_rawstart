import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class UserModel {
  String id_users;
  String? nbre_followers;
  FirebaseDateModel? expire_date;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  String? expire_date_db;
  String? created_at_db;
  String? updated_at_db;
  String? email;
  String? password;
  String? name;
  String? password_hash;
  String? uid;
  String? photo_url;
  String? phone;
  String? nbre_following;
  String? email_verified;
  String? id_annoncers;
  String? annoncer_compagny;
  FirebaseDateModel? annoncer_created_at;
  FirebaseDateModel? annoncer_updated_at;
  String? annoncer_picture_path;
  String? annoncer_cover_picture_path;
  String? annoncer_checkout_phone_number;
  String? annoncer_created_at_db;
  String? annoncer_updated_at_db;

  UserModel(
      {required this.id_users,
      this.nbre_followers,
      this.expire_date,
      this.created_at,
      this.updated_at,
        this.expire_date_db,
        this.created_at_db,
        this.updated_at_db,
      this.email,
      this.password,
      this.name,
      this.password_hash,
      this.uid,
      this.photo_url,
      this.phone,
      this.nbre_following,
      this.email_verified,
        this.id_annoncers,
        this.annoncer_compagny,
        this.annoncer_created_at,
        this.annoncer_updated_at,
        this.annoncer_picture_path,
        this.annoncer_cover_picture_path,
        this.annoncer_checkout_phone_number,
        this.annoncer_created_at_db,
        this.annoncer_updated_at_db});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id_users: json["id_users"].toString(),
      nbre_followers: (json["nbre_followers"] == null || json["nbre_followers"] == '') ? '0' : json["nbre_followers"].toString(),
      expire_date: (json["expire_date"] == null || json["expire_date"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["expire_date"]),
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      email: json["email"].toString(),
      password: json["password"].toString(),
      name: json["name"].toString(),
      password_hash: json["password_hash"].toString(),
      uid: json["uid"].toString(),
      photo_url: json["photo_url"].toString(),
      phone: json["phone"].toString(),
      nbre_following: (json["nbre_following"] == null || json["nbre_following"] == '') ? '0' : json["nbre_following"].toString(),
      email_verified: json["email_verified"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      annoncer_compagny: json["annoncer_compagny"].toString(),
      annoncer_picture_path: json["annoncer_picture_path"].toString(),
      annoncer_cover_picture_path: json["annoncer_cover_picture_path"].toString(),
      annoncer_checkout_phone_number: json["annoncer_checkout_phone_number"].toString(),
      annoncer_created_at: (json["annoncer_created_at"] == null || json["annoncer_created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["annoncer_created_at"]),
      annoncer_updated_at: (json["annoncer_updated_at"] == null || json["annoncer_updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["annoncer_updated_at"]),
    );
  }

  factory UserModel.fromJsonDb(Map<String, dynamic> json) {
    return UserModel(
      id_users: json["id_users"].toString(),
      nbre_followers: json["nbre_followers"].toString(),
      email: json["email"].toString(),
      expire_date_db: json["expire_date_db"].toString(),
      created_at_db: json["created_at"].toString(),
      updated_at_db: json["updated_at"].toString(),
      password: json["password"].toString(),
      name: json["name"].toString(),
      password_hash: json["password_hash"].toString(),
      uid: json["uid"].toString(),
      photo_url: json["photo_url"].toString(),
      phone: json["phone"].toString(),
      nbre_following: json["nbre_following"].toString(),
      email_verified: json["email_verified"].toString(),

      id_annoncers: json["id_annoncers"].toString(),
      annoncer_compagny: json["annoncer_compagny"].toString(),
      annoncer_picture_path: json["annoncer_picture_path"].toString(),
      annoncer_cover_picture_path: json["annoncer_cover_picture_path"].toString(),
      annoncer_checkout_phone_number: json["annoncer_checkout_phone_number"].toString(),
      annoncer_created_at_db: json["annoncer_created_at"].toString(),
      annoncer_updated_at_db: json["annoncer_updated_at"].toString(),
    );
  }
}