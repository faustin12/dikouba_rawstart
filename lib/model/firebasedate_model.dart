class FirebaseDateModel {
  String _seconds;
  String _nanoseconds;

  FirebaseDateModel(
      this._seconds, this._nanoseconds);

  factory FirebaseDateModel.fromJson(Map<String, dynamic> json) {
    return FirebaseDateModel(json["_seconds"].toString(), json["_nanoseconds"].toString());
  }

  String get seconds => _seconds;

  set seconds(String value) {
    _seconds = value;
  }

  String get nanoseconds => _nanoseconds;

  set nanoseconds(String value) {
    _nanoseconds = value;
  }

  Map<String, dynamic> toJsonSimple() => {
    '_seconds': this._seconds,
    '_nanoseconds': this._nanoseconds,
  };
  String toRYString() => '{"_seconds": "${this._seconds}","_nanoseconds": "${this._nanoseconds}"}';
}