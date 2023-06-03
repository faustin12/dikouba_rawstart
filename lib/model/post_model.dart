import 'package:dikouba_rawstart/model/annoncer_model.dart';
import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class PostModel {
  String? id_evenements;
  String? nbre_likes;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  String? id_annoncers;
  String? media;
  String? id_posts;
  String? type;
  String? nbre_comments;
  EvenementModel? evenements;
  AnnoncerModel? annoncers;
  String? description;

  PostModel(
      {this.created_at,
      this.updated_at,
      this.nbre_likes,
      this.id_annoncers,
      this.evenements,
      this.annoncers,
      this.media,
      this.description,
      this.id_posts,
      this.type,
      this.id_evenements,
      this.nbre_comments});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      created_at: (json["created_at"] == null || json["created_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["updated_at"]),
      evenements: (json["evenements"] == null || json["evenements"] == '')
          ? new EvenementModel(banner_path: '')
          : EvenementModel.fromJson(json["evenements"]),
      annoncers: (json["annoncers"] == null || json["annoncers"] == '')
          ? new AnnoncerModel()
          : AnnoncerModel.fromJson(json["annoncers"]),
      description: json["description"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      nbre_comments: json["nbre_comments"].toString(),
      nbre_likes: json["nbre_likes"].toString(),
      media: (json["media"] == null) ? '' : json["media"].toString(),
      id_evenements: json["id_evenements"].toString(),
      type: json["type"].toString(),
      id_posts: json["id_posts"].toString(),
    );
  }
  String toRYString() =>
      '{"media": "${this.media}","description": "${this.description}","evenements": ${this.evenements?.toRYString()},"nbre_comments": ${this.nbre_comments},"nbre_likes": ${this.nbre_likes},"type": ${this.type},"created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}
