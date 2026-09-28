import 'package:material_ui/material_ui.dart';

class FooterTile extends StatelessWidget {
  const FooterTile({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
        ),
        child: Center(child: child),
      );
}
