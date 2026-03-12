import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProductImage({super.key, required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      'assets/images/placeholder.png',
      height: size,
      width: size,
      fit: BoxFit.cover,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              height: size,
              width: size,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  SizedBox(height: size, width: size),
              errorWidget: (context, url, error) => placeholder,
            )
          : placeholder,
    );
  }
}
