import 'package:dikouba_rawstart/model/firebasedate_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';

class EvenementCommentModel {
  String? id_evenements;
  String? id_users;
  String? content;
  String? id_comments;
  String? is_suspended;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  UserModel? users;

  EvenementCommentModel(
      {this.id_evenements,
      this.id_users,
      this.content,
      this.id_comments,
      this.is_suspended,
      this.created_at,
      this.updated_at,
      this.users});

  factory EvenementCommentModel.fromJson(Map<String, dynamic> json) {
    return EvenementCommentModel(
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      id_evenements: json["id_evenements"].toString(),
      id_users: json["id_users"].toString(),
      content: json["content"].toString(),
      id_comments: json["id_comments"].toString(),
      is_suspended: json["is_suspended"].toString(),
      users: (json["users"] == null || json["users"] == '') ? new UserModel(id_users: '') : UserModel.fromJson(json["users"]),
    );
  }
  // String toRYString() => '{"title": "${this.title}","description": "${this.description}","id_categories": "${this.id_categories}","users": ${this.users.toRYString()},"created_at": ${this.created_at.toRYString()},"updated_at": ${this.updated_at.toRYString()}}';

}
