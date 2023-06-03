
class TransactionModel {
  String? message;
  String? revenue;
  String? created_date;
  String? mobile_operator_name_short;
  String? mobile_operator_name;
  String? currency;
  String? country_name;
  String? region_name;
  String? status;
  String? amount;
  String? fee;
  String? msisdn;
  String? email;
  String? transaction_UUID;

  TransactionModel(
      {this.message,
      this.revenue,
      this.created_date,
      this.mobile_operator_name_short,
      this.mobile_operator_name,
      this.currency,
      this.country_name,
      this.region_name,
      this.status,
      this.amount,
      this.fee,
      this.msisdn,
      this.email,
      this.transaction_UUID});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      // message: json["message"].toString(),
      // revenue: json["revenue"].toString(),
      // created_date: json["created_date"].toString(),
      // mobile_operator_name_short: json["mobile_operator_name_short"].toString(),
      // mobile_operator_name: json["mobile_operator_name"].toString(),
      // currency: json["currency"].toString(),
      // country_name: json["country_name"].toString(),
      // region_name: json["region_name"].toString(),
      // status: json["status"].toString(),
      amount: json["amount"].toString(),
      fee: json["fee"].toString(),
      msisdn: json["msisdn"].toString(),
      // email: json["email"].toString(),
      // transaction_UUID: json["transaction_UUID"].toString(),
    );
  }
}
