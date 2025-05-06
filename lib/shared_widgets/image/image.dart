import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum ImageViewType {
  network,
  asset,
  file,
}

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.type,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  factory AppImage.network({
    Key? key,
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return AppImage(
      key: key,
      type: ImageViewType.network,
      url: url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }

  factory AppImage.asset({
    Key? key,
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return AppImage(
      key: key,
      type: ImageViewType.asset,
      url: url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }

  factory AppImage.file({
    Key? key,
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return AppImage(
      key: key,
      type: ImageViewType.file,
      url: url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }

  final ImageViewType type;
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = SizedBox(
      width: width,
      height: height,
    );

    switch (type) {
      case ImageViewType.network:
        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          memCacheHeight: height?.toInt(),
          memCacheWidth: width?.toInt(),
          fit: fit,
          placeholder: (context, url) => placeholder,
          errorWidget: (context, url, error) => placeholder,
        );
      case ImageViewType.asset:
        return Image.asset(
          url,
          width: width,
          height: height,
          cacheHeight: height?.toInt(),
          cacheWidth: width?.toInt(),
          fit: fit,
          errorBuilder: (context, _, __) => placeholder,
        );
      case ImageViewType.file:
        return Image.file(
          File(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => placeholder,
          cacheHeight: height?.toInt(),
          cacheWidth: width?.toInt(),
        );
    }
  }
}

// class AppImageFromPathWidget extends StatefulWidget {
//   const AppImageFromPathWidget({
//     super.key,
//     required this.path,
//     this.width,
//     this.height,
//     required this.fit,
//   });
//
//   final String path;
//   final double? width;
//   final double? height;
//   final BoxFit fit;
//
//   @override
//   State<AppImageFromPathWidget> createState() => _AppImageFromPathWidgetState();
// }
//
// class _AppImageFromPathWidgetState extends State<AppImageFromPathWidget> {
//   final UploadImageRepository _uploadFileRepository = getIt.get();
//
//   @override
//   void didUpdateWidget(covariant AppImageFromPathWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.path != widget.path) {
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String>(
//       future: _uploadFileRepository.getUrlImage(imagePath: widget.path),
//       builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//         if (snapshot.hasData) {
//           final String url = snapshot.data.toString();
//           return AppImage.network(
//             url: url,
//             width: widget.width,
//             height: widget.height,
//             fit: widget.fit,
//           );
//         }
//         return SizedBox(
//           width: widget.width,
//           height: widget.height,
//         );
//       },
//     );
//   }
// }

// class AppAvatar extends StatelessWidget {
//   const AppAvatar({
//     super.key,
//     required this.path,
//     this.size = 48,
//   });
//
//   final String path;
//   final double size;
//
//   @override
//   Widget build(BuildContext context) {
//     if (path.isNotEmpty) {
//       return Container(
//         width: size,
//         height: size,
//         clipBehavior: Clip.antiAlias,
//         decoration: const BoxDecoration(shape: BoxShape.circle),
//         child: AppImage.file(
//           url: path,
//           width: size,
//           height: size,
//           fit: BoxFit.cover,
//         ),
//       );
//     }
//
//     return AppIcon(
//       IconPath.accountCircleStroke,
//       width: size,
//       height: size,
//     );
//   }
// }
