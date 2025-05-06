import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension DateTimeUtils on DateTime? {
  //calculate now - this explain for notification
  // by minutes
  // by hours
  // by days
  // if more than 3 days show date
  String get timeAgo {
    if (this == null) {
      return '';
    }

    final now = DateTime.now().toUtc();
    final difference = now.difference(this!);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 3) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(this!);
    }
  }

  String get time {
    if (this == null) {
      return 'HH:mm';
    }
    return DateFormat('HH:mm').format(this!);
  }

  String get date {
    if (this == null) {
      return 'dd/MM/yyyy';
    }

    return DateFormat('dd/MM/yyyy').format(this!);
  }

  int countDays(DateTime other) {
    final difference = this!.difference(other);
    return difference.inDays;
  }

  int get countToNow {
    return countDays(DateTime.now());
  }

  static DateTime now() {
    return DateTime.now();

    final now = DateTime.now();
    // final dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(now.toString(), true);
    // return dateTime.toLocal();

    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  static DateTime combineDateTime(DateTime startDate, TimeOfDay startTime) {
    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
  }

  static String formatTimeFromDateTime(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString()}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    } else if (minutes > 0) {
      return '${minutes.toString()}m:${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds.toString()}s';
    }
  }

  String get dateTimeServiceDisplay {
    if (this == null) {
      return '---';
    }
    return DateFormat('[HH:mm] dd/MM/yyyy').format(this!);
  }

  static DateTime getOnlyDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  //compare two dates
  static int compareByDate(DateTime dateTime, DateTime other) {
    if (dateTime.year < other.year) {
      return -1;
    } else if (dateTime.year > other.year) {
      return 1;
    } else {
      if (dateTime.month < other.month) {
        return -1;
      } else if (dateTime.month > other.month) {
        return 1;
      } else {
        if (dateTime.day < other.day) {
          return -1;
        } else if (dateTime.day > other.day) {
          return 1;
        } else {
          return 0;
        }
      }
    }
  }

  bool isSameDate(DateTime other) {
    return DateTimeUtils.compareByDate(this!, other) == 0;
  }

  bool isBeforeDate(DateTime other) {
    return DateTimeUtils.compareByDate(this!, other) == -1;
  }

  bool isAfterDate(DateTime other) {
    return DateTimeUtils.compareByDate(this!, other) == 1;
  }
}

extension TimeOfDayUtils on TimeOfDay? {
  String get time {
    if (this == null) {
      return 'HH:mm';
    }

    // return DateFormat('HH:mm').format(this!);
    final String hour = this!.hour.toString().padLeft(2, '0');
    final String minute = this!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime? get dateTime {
    if (this == null) {
      return null;
    }
    return DateTime(0, 0, 0, this!.hour, this!.minute);
  }
}

extension CompareTimeOfDayUtils on TimeOfDay {
  bool isBefore(TimeOfDay other) {
    if (hour < other.hour) {
      return true;
    } else if (hour == other.hour) {
      return minute < other.minute;
    } else {
      return false;
    }
  }

  bool isAfter(TimeOfDay other) {
    if (hour > other.hour) {
      return true;
    } else if (hour == other.hour) {
      return minute > other.minute;
    } else {
      return false;
    }
  }
}
