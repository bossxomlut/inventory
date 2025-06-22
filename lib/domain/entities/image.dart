import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.freezed.dart';
part 'image.g.dart';

@freezed
class ImageStorageModel with _$ImageStorageModel {
  const factory ImageStorageModel({
    required int id,
    String? path,
  }) = _ImageStorageModel;

  factory ImageStorageModel.fromJson(Map<String, dynamic> json) => _$ImageStorageModelFromJson(json);
}
