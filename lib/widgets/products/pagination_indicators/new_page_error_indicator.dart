import 'package:flutter/material.dart';
import './footer_tile.dart';

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({
    Key? key,
    this.onTap,
  }) : super(key: key);
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: const FooterTile(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Noe gikk galt. Trykk for å prøve igjen.',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 4,
              ),
              Icon(
                Icons.refresh,
                size: 16,
              ),
            ],
          ),
        ),
      );
}
