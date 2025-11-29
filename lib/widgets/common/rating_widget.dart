import 'package:flutter/material.dart';

Widget createRatingBar(
    {double rating = 5, double size = 24, required Color color}) {
  if (rating < 0) {
    rating = 0;
  } else if (rating > 5) {
    rating = 5;
  }

  bool absolute = false;
  int fullStar = 0;
  int emptyStar = 0;

  if (rating == 0 ||
      rating == 1 ||
      rating == 2 ||
      rating == 3 ||
      rating == 4 ||
      rating == 5) {
    absolute = true;
  } else {
    double dec = (rating - int.parse(rating.toString().substring(0, 1)));
    if (dec > 0 && dec < 1) {
      if (dec >= 0.25 && dec <= 0.75) {
        absolute = false;
      } else {
        absolute = true;
        if (dec < 0.25) {
          emptyStar = 1;
        } else if (dec > 0.75) {
          fullStar = 1;
        }
      }
    }
  }
  return Row(
    children: [
      for (int i = 1; i <= rating + fullStar; i++)
        Icon(Icons.star, color: color, size: size),
      !absolute
          ? Icon(Icons.star_half, color: color, size: size)
          : const SizedBox.shrink(),
      for (int i = 1; i <= (5 - rating + emptyStar); i++)
        Icon(Icons.star_border, color: color, size: size),
    ],
  );
}
