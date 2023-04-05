class UserLimit {
  int max;
  int min;
  String measure;

  UserLimit(this.max, this.min, this.measure);

  factory UserLimit.fromJson(Map<dynamic, dynamic> json) => UserLimit(
      json['max'] as int, json['min'] as int, json['measure'] as String);

  Map<dynamic, dynamic> toJson() => {
        'max': max,
        'min': min,
        'measure': measure,
      };
}
