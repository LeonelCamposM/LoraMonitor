class UserLimit {
  double max;
  double min;
  String measure;

  UserLimit(this.max, this.min, this.measure);

  factory UserLimit.fromJson(Map<dynamic, dynamic> json) => UserLimit(
      json['max'] as double, json['min'] as double, json['measure'] as String);

  Map<dynamic, dynamic> toJson() => {
        'max': max,
        'min': min,
        'measure': measure,
      };
}
