import 'dart:io';

import 'package:equatable/equatable.dart';

class AppFile extends Equatable {
  final String name;
  final String path;

  const AppFile({required this.name, required this.path});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
    };
  }

  static AppFile fromJson(Map json) {
    return AppFile(
      name: json['name'].toString(),
      path: json['path'].toString(),
    );
  }

  String get type => _getFileType();

  String _getFileType() {
    final l = path.split(".");
    if (l.length > 1) {
      return l.last;
    }

    throw UnknownFileTypeException();
  }

  @override
  List<Object?> get props => [
        name,
        path,
      ];

  AppFile copyWith({
    String? name,
    String? path,
  }) {
    return AppFile(
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }
}

class Base64File extends AppFile {
  Base64File(this.base64) : super(name: '', path: '');

  final String base64;
}

class UnknownFileTypeException implements Exception {}

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split("/").last;
  }
}
