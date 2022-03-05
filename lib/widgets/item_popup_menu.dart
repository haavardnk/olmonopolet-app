import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showPopupMenu(BuildContext context, tapPosition, overlay, product) {
  showMenu<String>(
    position:
        RelativeRect.fromSize(tapPosition & const Size(40, 40), overlay.size),
    items: <PopupMenuEntry<String>>[
      if (product.untappdUrl != null)
        PopupMenuItem(
          value: 'untappd',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Untappd"),
            ],
          ),
        ),
      if (product.vmpUrl != null)
        PopupMenuItem(
          value: 'vinmonopolet',
          child: Row(
            children: <Widget>[
              Icon(Icons.open_in_browser),
              Text(" Vinmonopolet"),
            ],
          ),
        )
    ],
    context: context,
  ).then((value) {
    if (value == null) {
      return;
    }
    if (value == "untappd") {
      launch(product.untappdUrl!);
    }
    if (value == "vinmonopolet") {
      launch(product.vmpUrl!);
    }
  });
}
