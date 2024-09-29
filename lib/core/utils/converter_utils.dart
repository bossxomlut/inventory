import 'package:json_annotation/json_annotation.dart';

const JsonSerializable customJsonSerializable = JsonSerializable(
  converters: [
    CustomNullableStringConverter(),
  ],
);

class CustomDateTimeConverter implements JsonConverter<DateTime, String> {
  const CustomDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    if (json.contains(".")) {
      json = json.substring(0, json.length - 1);
    }

    return DateTime.parse(json);
  }

  @override
  String toJson(DateTime json) => json.toIso8601String();
}

class CustomNullableStringConverter implements JsonConverter<String?, dynamic> {
  const CustomNullableStringConverter();

  @override
  String? fromJson(dynamic json) {
    if (json != null) {
      return json.toString();
    }

    return null;
  }

  @override
  String? toJson(String? object) {
    return object;
  }
}
