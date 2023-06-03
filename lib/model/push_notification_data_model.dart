
class PushNotificationDataModel {
  String? type;
  String? page;
  String? exist;

  PushNotificationDataModel(
      {this.type,
        this.page,
      this.exist});

  factory PushNotificationDataModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationDataModel(
        type: json["type"].toString(),
      page: json["page"].toString(),
      exist: json["exist"].toString(),
    );
  }

  factory PushNotificationDataModel.fromJsonDb(Map<String, dynamic> json) {
    return PushNotificationDataModel(
      type: json["type"].toString(),
      page: json["page"].toString(),
      exist: json["exist"].toString(),
    );
  }
}