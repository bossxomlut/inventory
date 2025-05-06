import 'dart:developer';

import 'package:intl/intl.dart';

extension ParseFromMap on Map {
  String? parseString(String key) {
    final value = this[key];

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  int? parseInt(String key) {
    return this[key]?.toString().parseInt();
  }

  double? parseDouble(String key) {
    return this[key]?.toString().parseDouble();
  }

  bool? parseBool(String key) {
    return this[key]?.toString().parseBool();
  }

  DateTime? parseDate(String key) {
    return this[key]?.toString().parseDate();
  }

  DateTime? parseDate2(String key) {
    return this[key]?.toString().parseDate2();
  }

  DateTime? parseDate3(String key) {
    return this[key]?.toString().parseDate3();
  }

  DateTime? parseDateTime(String key) {
    return this[key]?.toString().parseDateTime();
  }

  // Color? parseColor(String key) {
  //   return this[key]?.toString().parseColor();
  // }

  List<T>? parsePureList<T>(String key) {
    try {
      return this[key] is List ? (this[key] as List).map((e) => e as T).toList() : null;
    } catch (e, st) {
      log("parse list error: $st");
      return null;
    }
  }

  List<T>? parseObjectList<T>(String key, T Function(Map json) parseFunction) {
    return parseList(this[key], parseFunction);
  }

  Map? parseMap(String key) {
    try {
      return this[key] is Map ? this[key] as Map : null;
    } catch (e) {
      return null;
    }
  }
}

extension ParseFromString on String? {
  int? parseInt() {
    if (this == null) {
      return null;
    }

    return int.tryParse(this!);
  }

  double? parseDouble() {
    if (this == null) {
      return null;
    }

    return double.tryParse(this!);
  }

  bool? parseBool() {
    if (this == null) {
      return null;
    }
    if (this == 'true' || this == '1') {
      return true;
    } else if (this == 'false' || this == '0') {
      return false;
    }

    return null;
  }

  DateTime? parseDate() {
    if (this == null) {
      return null;
    }
    try {
      return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(this!);
    } catch (_) {
      return null;
    }
  }

  DateTime? parseDate2() {
    if (this == null) {
      return null;
    }
    try {
      return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(this!);
    } catch (_) {
      return null;
    }
  }

  DateTime? parseDate3() {
    if (this == null) {
      return null;
    }
    try {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(this!);
    } catch (_) {
      return null;
    }
  }

  DateTime? parseDateTime() {
    if (this == null) {
      return null;
    }
    return DateTime.tryParse(this!);
  }
}

List<T>? parseList<T>(dynamic data, T Function(Map json) parseFunction) {
  if (data != null && data is List) {
    try {
      return data.map<T>((e) => parseFunction(e as Map)).toList();
    } catch (e, st) {
      log('error parsing: ${e.toString()}');
      log(st.toString());
    }
  }
  return null;
}

DateTime? parseDateFromTimeStamp(dynamic date) {
  try {
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    } else if (date is String) {
      return DateTime.fromMillisecondsSinceEpoch(date.toString().parseInt()! * 1000);
    }
  } catch (e) {}

  return null;
}
