import 'package:dikouba_rawstart/model/firebasedate_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';

class PostFavouriteModel {
  String? id_evenements;
  String? id_users;
  String? id_posts;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  UserModel? users;

  PostFavouriteModel(
      {this.created_at,
      this.updated_at,
      this.id_users,
      this.id_posts,
      this.users,
      this.id_evenements});

  factory PostFavouriteModel.fromJson(Map<String, dynamic> json) {
    return PostFavouriteModel(
      created_at: (json["created_at"] == null || json["created_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["updated_at"]),
      id_evenements: json["id_evenements"].toString(),
      id_users: json["id_users"].toString(),
      id_posts: json["type"].toString(),
      users: (json["users"] == null || json["users"] == '')
          ? new UserModel(id_users: '')
          : UserModel.fromJson(json["users"]),
    );
  }
  String toRYString() =>
      '{"id_users": ${this.id_users},"id_posts": ${this.id_posts},"id_evenements": ${this.id_evenements},"created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}
