import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class NotificationModel {
  String? image_path;
  String? description;
  String? id_notifications;
  String? title;
  String? status;
  String? action;
  String? id_users;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;

  NotificationModel(
      {
      this.image_path,
      this.description,
      this.id_notifications,
      this.title,
      this.status,
      this.action,
      this.id_users,
      this.created_at,
      this.updated_at});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      image_path: json["content"].toString(), //To be edited after back corrected
      description: json["content"].toString(), //To be edited after back corrected
      id_notifications: json["id_comments"].toString(), //To be edited after back corrected
      title: json["content"].toString(), //To be edited after back corrected
      status: json["is_suspended"].toString(), //To be edited after back corrected
      action: json["content"].toString(), //To be edited after back corrected
      id_users: json["id_users"].toString(),
      created_at: (json["created_at"] == null || json["created_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '')
          ? new FirebaseDateModel('', '')
          : FirebaseDateModel.fromJson(json["updated_at"]),
    );
  }
  String toRYString() =>
      '{"id_notifications": "${this.id_notifications}","id_users": "${this.id_users}","created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';
}
