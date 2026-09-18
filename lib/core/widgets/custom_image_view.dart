import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_shimmer.dart';
import '../constants/app_images.dart';

class CustomImageView extends StatelessWidget {
  final String imageUrl;
  final File? file;
  final double height;
  final double width;
  final BoxFit fit;
  final bool isAsset;

  const CustomImageView({
    super.key,
    this.imageUrl = '',
    this.file,
    this.height = 100,
    this.width = 100,
    this.fit = BoxFit.cover,
    this.isAsset = false,
  });

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppImages.logo,
          height: height,
          width: width,
          fit: BoxFit.contain,
        ),
      );
    }
    if (isAsset) {
      return Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppImages.logo,
          height: height,
          width: width,
          fit: BoxFit.contain,
        ),
      );
    }

    final String cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty ||
        (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://'))) {
      return Image.asset(
        AppImages.logo,
        height: height,
        width: width,
        fit: BoxFit.contain,
      );
    }

    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int? cacheWidth =
        width != double.infinity ? (width * pixelRatio).toInt() : null;
    final int? cacheHeight =
        height != double.infinity ? (height * pixelRatio).toInt() : null;

    return CachedNetworkImage(
      imageUrl: cleanUrl,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,

      placeholder: (context, url) =>
          CustomShimmer.rectangular(height: height, width: width),

      errorWidget: (context, url, error) => Image.asset(
        AppImages.logo,
        height: height,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
