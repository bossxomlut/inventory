import 'package:equatable/equatable.dart';

class ImageStorageModel extends Equatable {
  const ImageStorageModel({
    required this.id,
    this.path,
  });

  final int id;
  final String? path;

  @override
  List<Object?> get props => [id, path];
}
