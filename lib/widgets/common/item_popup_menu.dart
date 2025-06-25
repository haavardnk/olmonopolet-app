import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/app_launcher.dart';
import '../../models/product.dart';

Future<String?> showPopupMenu(BuildContext context, bool wishlisted,
    Offset tapPosition, RenderBox overlay, Product product) async {
  var value = await showMenu<String>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    position:
        RelativeRect.fromSize(tapPosition & const Size(40, 40), overlay.size),
    items: <PopupMenuEntry<String>>[
      if (product.untappdUrl != null)
        const PopupMenuItem(
          value: 'untappd',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Åpne i Untappd"),
            ],
          ),
        ),
      if (product.vmpUrl != null)
        const PopupMenuItem(
          value: 'vinmonopolet',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Åpne i Vinmonopolet"),
            ],
          ),
        )
    ],
    context: context,
  );

  if (value == "untappd") {
    AppLauncher.launchUntappd(product);
  }
  if (value == "vinmonopolet") {
    launchUrl(Uri.parse(product.vmpUrl!));
  }

  return null;
}
