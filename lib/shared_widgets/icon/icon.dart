import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

///Using SVG to display the icon
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain, // Mặc định là contain
  });

  ///Set package name for the icon
  ///Using for example project
  static String? _package;

  static void setPackage(String package) {
    _package = package;
  }

  final String assetName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      color: color,
      fit: fit,
      placeholderBuilder: (_) => SizedBox(width: width, height: height),
      package: _package,
    );
  }
}
