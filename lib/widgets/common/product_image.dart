import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? FancyShimmerImage(
              imageUrl: imageUrl!,
              height: size,
              width: size,
              boxFit: BoxFit.cover,
              errorWidget: Image.asset(
                'assets/images/placeholder.png',
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/images/placeholder.png',
              height: size,
              width: size,
              fit: BoxFit.cover,
            ),
    );
  }
}
