class FirebaseLocationModel {
  String address;
  String _latitude;
  String _longitude;

  FirebaseLocationModel(this.address,
      this._latitude, this._longitude);

  factory FirebaseLocationModel.fromJson(Map<String, dynamic> json) {
    return FirebaseLocationModel(json["address"].toString(), json["_latitude"].toString(), json["_longitude"].toString());
  }

  String get latitude => _latitude;

  set latitude(String value) {
    _latitude = value;
  }

  Map<String, dynamic> toJsonSimple() => {
    '_latitude': this._latitude,
    '_longitude': this._longitude,
    'address': this.address,
  };

  String get longitude => _longitude;

  set longitude(String value) {
    _longitude = value;
  }

  String toRYString() => '{"_longitude": "${this._longitude}","_latitude": "${this._latitude}"}';
}