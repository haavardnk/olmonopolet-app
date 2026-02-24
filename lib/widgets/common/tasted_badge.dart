import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth.dart';
import '../../utils/tasted_toggle.dart';

class TastedBadge extends StatefulWidget {
  final Product product;
  final ValueChanged<Product> onToggled;

  const TastedBadge({
    required this.product,
    required this.onToggled,
    super.key,
  });

  @override
  State<TastedBadge> createState() => _TastedBadgeState();
}

class _TastedBadgeState extends State<TastedBadge> {
  bool _loading = false;

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final updated = await toggleTasted(context, widget.product);
      if (updated != null) widget.onToggled(updated);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    if (!auth.isSignedIn) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final tasted = widget.product.userTasted;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: tasted ? colors.primary : colors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: _loading
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tasted ? colors.onPrimary : colors.onSurfaceVariant,
                ),
              )
            : Icon(
                tasted ? Icons.check : Icons.check_circle_outline,
                size: 16.r,
                color: tasted ? colors.onPrimary : colors.onSurfaceVariant,
              ),
      ),
    );
  }
}
