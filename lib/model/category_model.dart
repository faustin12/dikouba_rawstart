import 'package:dikouba_rawstart/model/firebasedate_model.dart';

class CategoryModel {
  String? id_categories;
  String? description;
  FirebaseDateModel? created_at;
  FirebaseDateModel? updated_at;
  String? title;

  CategoryModel(
      {this.title,
      this.created_at,
      this.updated_at,
      this.description,
      this.id_categories});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json["title"].toString(),
      created_at: (json["created_at"] == null || json["created_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["created_at"]),
      updated_at: (json["updated_at"] == null || json["updated_at"] == '') ? new FirebaseDateModel('', '') : FirebaseDateModel.fromJson(json["updated_at"]),
      description: json["description"].toString(),
      id_categories: json["id_categories"].toString(),
    );
  }
  String toRYString() => '{"title": "${this.title}","description": "${this.description}","id_categories": "${this.id_categories}","created_at": ${this.created_at?.toRYString()},"updated_at": ${this.updated_at?.toRYString()}}';

}
