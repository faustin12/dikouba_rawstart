import 'package:dikouba_rawstart/model/evenement_model.dart';
import 'package:dikouba_rawstart/model/sondage_model.dart';
import 'package:dikouba_rawstart/model/user_model.dart';

class SondageReponseModel {
  String id_sondages;
  String nombre_vote;
  String? description;
  String id_evenements;
  String valeur;
  String id_annoncers;
  String id_reponses;
  String id_users;
  UserModel? users;
  SondageModel? sondages;

  SondageReponseModel({required this.id_sondages, required this.nombre_vote, this.description, required this.id_users,
      required this.id_evenements, required this.valeur, required this.id_annoncers, required this.id_reponses, this.users, this.sondages});

  factory SondageReponseModel.fromJson(Map<String, dynamic> json) {
    return SondageReponseModel(
      description: json["description"].toString(),
      id_sondages: json["id_sondages"].toString(),
      id_users: json["id_users"].toString(),
      nombre_vote: json["nombre_vote"].toString(),
      id_evenements: json["id_evenements"].toString(),
      valeur: json["valeur"].toString(),
      id_annoncers: json["id_annoncers"].toString(),
      id_reponses: json["id_reponses"].toString(),
      users: (json["users"] == null || json["users"] == '') ? new UserModel(id_users: '') : UserModel.fromJson(json["users"]),
      sondages: (json["sondages"] == null || json["sondages"] == '') ? new SondageModel(evenements: new EvenementModel(banner_path: ''), id_sondages: '', reponses: [], reponsesusers: []) : SondageModel.fromJson(json["sondages"]),
    );
  }
  String toRYString() => '{"id_users": "${this.id_users}","id_reponses": "${this.id_reponses}","id_annoncers": "${this.id_annoncers}","valeur": "${this.valeur}","id_evenements": "${this.id_evenements}","nombre_vote": "${this.nombre_vote}","id_sondages": "${this.id_sondages}","description": "${this.description}"}';

}
