import 'package:dikouba_rawstart/model/category_model.dart';
import 'package:dikouba_rawstart/model/firebasedate_model.dart';
import 'package:dikouba_rawstart/model/firebaselocation_model.dart';

class EvenementModel {
  String? longitude;
  String? title;
  FirebaseLocationModel? location;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  FirebaseDateModel? start_date;
  String? start_date_tmp;
  String? end_date_tmp;
  FirebaseDateModel? end_date;
  CategoryModel? categories;
  EvenementModel? parent;
  String? description;
  String? nbre_tickets;
  String? id_annoncers;
  String? nbre_comments;
  String? nbre_packages;
  String banner_path;
  String? latitude;
  String? nbre_favoris;
  String? nbre_likes;
  String? nbre_participants;
  String? id_categories;
  String? id_evenements;
  String? parent_id;
  bool? has_like;
  bool? has_favoris;

  EvenementModel(
      {this.longitude,
      this.title,
      this.location,
      this.created_at,
      this.updated_at,
      this.start_date,
      this.end_date,
      this.description,
      this.nbre_tickets,
      this.id_annoncers,
      this.nbre_comments,
      this.nbre_packages,
      required this.banner_path,
      this.latitude,
      this.nbre_favoris,
      this.nbre_likes,
      this.nbre_participants,
      this.id_categories,
      this.id_evenements,
      this.categories,
      this.parent,
      this.parent_id,
      this.has_like,
      this.has_favoris});

  factory EvenementModel.fromJson(Map<String, dynamic> json) {
    return EvenementModel(
      longitude: json["longitude"].toString(),
      title: json["title"].toString(),
      location: (json["location"] == null || json["location"] == '') ? new FirebaseLocationModel('', '', '') : FirebaseLocationModel.fromJson(json["location"]),
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      start_date: (json["start_date"] == null || json["start_date"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["start_date"]),
      end_date: (json["end_date"] == null || json["end_date"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["end_date"]),
      categories: (json["categories"] == null || json["categories"] == '') ? new CategoryModel() : CategoryModel.fromJson(json["categories"]),
      parent: (json["parent"] == null || json["parent"] == '') ? new EvenementModel(banner_path: '') : EvenementModel.fromJson(json["parent"]),
      description: json["description"].toString(),
      nbre_tickets: (json["nbre_tickets"] == null) ? '0' : json["nbre_tickets"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      nbre_comments: (json["nbre_comments"] == null) ? '0' : json["nbre_comments"].toString(),
      nbre_packages: (json["nbre_packages"] == null) ? '0' : json["nbre_packages"].toString(),
      banner_path: (json["banner_path"] == null) ? '' : json["banner_path"].toString(),
      latitude: json["latitude"].toString(),
      nbre_favoris: (json["nbre_favoris"] == null) ? '0' : json["nbre_favoris"].toString(),
      nbre_likes: (json["nbre_likes"] == null) ? '0' : json["nbre_likes"].toString(),
      nbre_participants: (json["nbre_participants"] == null) ? '0' : json["nbre_participants"].toString(),
      id_categories: json["id_categories"].toString(),
      id_evenements: json["id_evenements"].toString(),
      parent_id: (json["parent_id"] == null) ? '' : json["parent_id"].toString(),
      has_favoris: (json["has_favoris"] == null) ? false : json["has_favoris"],
      has_like: (json["has_like"] == null) ? false : json["has_like"],
    );
  }

  String toRYString() => '{"has_favoris": "${this.has_favoris}","has_like": "${this.has_like}","parent_id": "${this.parent_id}","id_evenements": "${this.id_evenements}","id_categories": "${this.id_categories}","nbre_participants": "${this.nbre_participants}","nbre_likes": "${this.nbre_likes}","nbre_favoris": "${this.nbre_favoris}","banner_path": "${this.banner_path}","nbre_packages": "${this.nbre_packages}","nbre_comments": "${this.nbre_comments}","id_annoncers": "${this.id_annoncers}","nbre_tickets": "${this.nbre_tickets}","description": "${this.description}","end_date": ${this.end_date?.toRYString()},"start_date": ${this.start_date?.toRYString()},"title": "${this.title}","location": ${this.location?.toRYString()},"created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}